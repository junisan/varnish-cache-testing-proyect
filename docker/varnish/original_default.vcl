#https://medium.com/@carlos.compains/configuración-básica-de-varnish-f00280c55eb3
#https://www.drupal.org/docs/8/api/cache-api/cache-tags-varnish

vcl 4.0;

acl purge {
    "localhost";
    "192.168.1.0"/24;
    "172.17.0.1/24";
}


backend default {
  .host = "local.estrategiasdeinversion.com";
  .port = "80";
}

sub vcl_recv {
  if (req.method != "GET" && req.method != "HEAD" || req.http.Authorization) {
    return (pass);
  }

  if(req.url ~ "^/a_t_e" || req.url ~ "^/caja-login"
    || req.url ~ "^/login" || req.url ~ "^/logout" || req.url ~ "^/app_dev.php" ){
    return (pass);
  }

  if(req.url ~ "^/favoritos" || req.url ~ "^/premium" || req.url ~ "/ei-admin"){
    return (pass);
  }

  if(req.method == "GET" && req.url ~ "/destroy-cache-group") {
    if (!client.ip ~ purge) {
      return (synth(403, "Not allowed"));
    }

    if (req.http.Cache-Tag) {
      ban("obj.http.Cache-Tag ~ " + req.http.Cache-Tag);
      return(synth(200, "Ban added"));
    } else {
      return (synth(500, "Cache-Tag header missing."));
    }
  }

  if(req.method == "PURGE") {
    if (!client.ip ~ purge) {
      return (synth(403, "Not allowed"));
    }
    return (purge);
  }

  unset req.http.Cache-Control;
  unset req.http.pragma;
  ##unset req.http.Cookie;
  unset req.http.Accept-Encoding;
  unset req.http.Vary;
  unset req.http.Accept-Language;
  return (hash);
}

sub vcl_purge {
  set req.method = "GET";
  return (restart);
}

sub vcl_pass {
  set req.http.X-Live = 1;
  unset req.http.If-None-Match;
  unset req.http.If-Modified-Since;
}

sub vcl_miss {
  unset req.http.If-None-Match;
  unset req.http.If-Modified-Since;
  return (fetch);
}

sub vcl_backend_fetch {
  unset bereq.http.If-None-Match;
  unset bereq.http.If-Modified-Since;
}

sub vcl_backend_response {
  if (bereq.http.X-Live == "1") {
      set beresp.http.X-Live = 1;
      return (deliver);
  }

  unset beresp.http.expires;
  unset beresp.http.Set-Cookie;

  if(beresp.status != 200) {
    set beresp.ttl = 0s;
    set beresp.uncacheable = true;
  }
}

sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
}

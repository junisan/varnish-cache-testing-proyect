<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class DefaultController extends AbstractController
{
    /**
     * @Route("/", name="home")
     */
    public function home(): Response
    {
        $response = $this->render('home.html.twig');
//        return $this->makePublic($response);
        return $response;
    }

    /**
     * @Route("/public", name="publicNews")
     */
    public function publicPage(): Response
    {
        $response = $this->render('publico.html.twig');
        return $this->makePublic($response);
    }

    /**
     * @Route("/private", name="privateNews")
     */
    public function privatePage(): Response
    {
        $response = $this->render('privado.html.twig');
        return $this->makePrivate($response);
    }

    /**
     * @Route("/publicModule", name="publicModule")
     */
    public function publicModule(): Response
    {
        $response = $this->render('modulo.html.twig', [
            'titulo' => 'Anda! Un módulo públicos',
            'contenido' => 'Lo que hay aquí es visible por todos'
        ]);

        return $this->makePublic($response, 180);
    }

    /**
     * @Route("/privateModule", name="privateModule")
     */
    public function privateModule(): Response
    {
        $response = $this->render('modulo.html.twig', [
            'titulo' => 'Ehh!! Módulo privado',
            'contenido' => 'Circule! No hay nada que ver'
        ]);

        return $this->makePrivate($response);
    }

    protected function makePublic(Response $response, int $max = 60): Response
    {
        $response->setPublic();
        $response->setMaxAge($max);
        $response->setSharedMaxAge($max);
        return $response;
    }

    protected function makePrivate(Response $response): Response
    {
        $response->setMaxAge(0);
        $response->setSharedMaxAge(0);
        $response->setPrivate();
        return $response;
    }
}
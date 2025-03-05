<?php

declare(strict_types=1);

namespace App\Controller;

use App\Entity\User;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\CurrentUser;
use Doctrine\DBAL\Exception\UniqueConstraintViolationException;

class AuthController extends AbstractController
{
    #[Route('/secured', name: 'api_secured', methods: ['GET'])]
    public function securedEndpoint(): JsonResponse
    {
        // Cette route est protégée et nécessite une authentification
        /** @var User $user */
        $user = $this->getUser();
        
        return $this->json([
            'message' => 'Vous êtes authentifié',
            'user' => $user->getUserIdentifier(),
        ]);
    }

    #[Route('/login', name: 'api_login', methods: ['POST'])]
    public function login(): JsonResponse
    {
        // Cette méthode ne sera jamais exécutée car le firewall JWT intercepte la requête
        throw new \LogicException('Cette méthode peut être vide - elle ne sera jamais exécutée !');
    }

    #[Route('/register', name: 'api_register', methods: ['POST'])]
    public function register(
        Request $request,
        UserPasswordHasherInterface $passwordHasher,
        EntityManagerInterface $entityManager,
        UserRepository $userRepository
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if (empty($data['email']) || empty($data['password'])) {
            return $this->json([
                'message' => 'Email et mot de passe requis',
            ], Response::HTTP_BAD_REQUEST);
        }

        // Vérifier si l'email existe déjà
        $existingUser = $userRepository->findOneBy(['email' => $data['email']]);
        if ($existingUser) {
            return $this->json([
                'message' => 'Cet email est déjà utilisé',
            ], Response::HTTP_CONFLICT);
        }

        try {
            $user = new User();
            $user->setEmail($data['email']);
            $user->setPassword($passwordHasher->hashPassword($user, $data['password']));
            $user->setRoles(['ROLE_USER']);

            $entityManager->persist($user);
            $entityManager->flush();

            return $this->json([
                'message' => 'Utilisateur créé avec succès',
            ], Response::HTTP_CREATED);
        } catch (UniqueConstraintViolationException $e) {
            // Au cas où la vérification précédente n'aurait pas fonctionné (race condition)
            return $this->json([
                'message' => 'Cet email est déjà utilisé',
            ], Response::HTTP_CONFLICT);
        } catch (\Exception $e) {
            return $this->json([
                'message' => 'Une erreur est survenue lors de la création de l\'utilisateur',
                'error' => $e->getMessage(),
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    #[Route('/me', name: 'api_me', methods: ['GET'])]
    public function me(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        
        return $this->json([
            'email' => $user->getEmail(),
            'roles' => $user->getRoles(),
        ]);
    }
}

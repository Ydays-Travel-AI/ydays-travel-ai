<?php

declare(strict_types=1);

namespace App\Controller;

use App\Entity\User;
use App\Repository\UserRepository;
use App\Service\ValidationService;
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
    public function __construct(
        private ValidationService $validationService
    ) {
    }

    #[Route('/login', name: 'api_login', methods: ['POST'])]
    public function login(): JsonResponse
    {
        // Cette méthode ne sera quasiment jamais exécutée car le firewall JWT intercepte la requête (voir config/packages/security.yaml)
        return $this->json([
            'message' => "Désolé, l'authentification n'est pas disponible pour le moment.",
        ]);
    }

    #[Route('/register', name: 'api_register', methods: ['POST'])]
    public function register(
        Request $request,
        UserPasswordHasherInterface $passwordHasher,
        EntityManagerInterface $entityManager,
        UserRepository $userRepository
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);
        $email = $data['email'] ?? '';
        $password = $data['password'] ?? '';

        if (empty($email) || empty($password)) {
            return $this->json([
                'message' => 'Email et mot de passe requis',
            ], Response::HTTP_BAD_REQUEST);
        }

        // Validation de l'email
        if (!$this->validationService->isValidEmail($email)) {
            return $this->json([
                'message' => 'Email invalide',
            ], Response::HTTP_BAD_REQUEST);
        }

        // Validation du mot de passe
        $passwordErrors = $this->validationService->isValidPassword($password);
        if (!empty($passwordErrors)) {
            return $this->json([
                'message' => 'Le mot de passe ne respecte pas les critères de sécurité',
                'errors' => $passwordErrors,
            ], Response::HTTP_BAD_REQUEST);
        }

        // Vérifier si l'email existe déjà
        $existingUser = $userRepository->findOneBy(['email' => $email]);
        if ($existingUser) {
            return $this->json([
                'message' => 'Cet email est déjà utilisé',
            ], Response::HTTP_CONFLICT);
        }

        try {
            $user = new User();
            $user->setEmail($email);
            $user->setPassword($passwordHasher->hashPassword($user, $password));
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
}

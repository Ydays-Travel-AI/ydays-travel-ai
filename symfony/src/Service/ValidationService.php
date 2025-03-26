<?php

declare(strict_types=1);

namespace App\Service;

class ValidationService
{
    /**
     * Vérifie si l'email est valide
     */
    public function isValidEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Vérifie si le mot de passe respecte les critères de sécurité
     */
    public function isValidPassword(string $password): array
    {
        $errors = [];

        if (strlen($password) < 8) {
            $errors[] = 'Le mot de passe doit contenir au moins 8 caractères';
        }

        if (!preg_match('/[A-Z]/', $password)) {
            $errors[] = 'Le mot de passe doit contenir au moins une majuscule';
        }

        if (!preg_match('/[a-z]/', $password)) {
            $errors[] = 'Le mot de passe doit contenir au moins une minuscule';
        }

        if (!preg_match('/[!@#$%^&*(),.?":{}|<>_\-\\[\];\'/+=`~]/', $password)) {
            $errors[] = 'Le mot de passe doit contenir au moins un caractère spécial';
        }

        if (!preg_match('/[0-9]/', $password)) {
            $errors[] = 'Le mot de passe doit contenir au moins un chiffre';
        }

        return $errors;
    }
}

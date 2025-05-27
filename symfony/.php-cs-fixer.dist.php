<?php

declare(strict_types=1);

return (new PhpCsFixer\Config())
    ->setRules([
        '@Symfony' => true, // Règles Symfony uniquement
        'strict_param' => true, // Paramètres stricts
        'declare_strict_types' => true, // Activer strict_types
        'array_syntax' => ['syntax' => 'short'], // Tableaux courts []
        'single_quote' => true, // Guillemets simples
        'trailing_comma_in_multiline' => true, // Virgules finales en multilignes
        'no_unused_imports' => true, // Suppression des imports inutilisés
    ])
    ->setRiskyAllowed(true)
    ->setFinder((new PhpCsFixer\Finder())
        ->in(__DIR__.'/src')
        ->append(['.php-cs-fixer.dist.php'])
        ->name('*.php')
        ->notName('*.blade.php')
        // ->ignoreDotFiles(true)
        ->ignoreVCS(true));

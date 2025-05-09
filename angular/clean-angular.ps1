Write-Host "Nettoyage du projet Angular..."

# Fermer les processus node
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force

# Supprimer cache Angular
if (Test-Path ".angular\cache") {
    Remove-Item -Recurse -Force ".angular\cache"
    Write-Host "Cache Angular supprimé"
}

# Supprimer node_modules & package-lock.json
Remove-Item -Recurse -Force "node_modules"
Remove-Item -Force "package-lock.json"

# Réinstallation
Write-Host "Réinstallation des dépendances..."
npm install

Write-Host "Nettoyage terminé !"

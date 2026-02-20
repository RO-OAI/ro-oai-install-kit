# Instalare si verificare

## Pasul 1
Pentru a putea rula scripurile de instalare si verificare trebuie sa setamp un execution policy mai permisiv daca nu este deja setat.
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

## Pasul 1
Se porneste un "Terminal" ca Administrator si se ruleaza comanda de mai jos pentru a instal kit-ul.
```powershell
.\install.ps1
```

## Pasul 2

Se restarteaza calculatorul si se asteapta sa porneasca Docker Desktop

## Pasul 3
Se porneste un "Terminal" si se ruleaza comanda de mai jos pentru a continua instalarea kit-ului.

```powershell
.\post-install.ps1
```
# Instalare si verificare

Toate instructiunile se ruleaza autentificat ca utilizatorul care o sa fie folosit de elevi in timpul competitiei.

## Pasul 1
Pentru a putea rula scripurile de instalare si verificare trebuie sa setamp un execution policy mai permisiv daca nu este deja setat.
Se porneste un "Terminal" ca Administrator si se ruleaza comanda de mai jos pentru a modifica execution policy-ul. Dupa ce se ruleaza toate comenzi se poate pune execution policy-ul la default.
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

## Pasul 2
Se porneste un "Terminal" ca Administrator si se ruleaza comanda de mai jos pentru a instal kit-ul.
```powershell
.\install.ps1
```

## Pasul 3

Se restarteaza calculatorul, se asteapta sa porneasca Docker Desktop si se da "Skip" la login.

## Pasul 4
Se porneste un "Terminal" si se ruleaza comanda de mai jos pentru a continua instalarea kit-ului.

```powershell
.\post-install.ps1
```

# Inainte de competitie / dupa finalizarea competitiei
Inainte ca elevii sa intre in salile de competitie se executa scriptul `restrict.bat` ca administrator pentru a restrictiona accesul la internet.  La prompt se raspunde `y`.
Dupa finalizarea competitiei pentru restaurarea accesului la internet se executa scriptul `restrict.bat` ca administrator.  La prompt se raspunde raspunde `n`.

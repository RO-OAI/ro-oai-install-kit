# Instrucțiuni de Instalare și Verificare (Kit Olimpiada AI)

Urmați pașii de mai jos pentru a configura mediul de lucru pentru concurs. 

**IMPORTANT:** Toate instrucțiunile trebuie executate fiind autentificat cu **utilizatorul de Windows care va fi folosit de elevi** în timpul competiției.

---

## Descărcarea Kitului

1. Accesați pagina GitHub a proiectului.
2. Apăsați butonul verde **"Code"**.
3. Selectați **"Download ZIP"**.
4. Dezarhivați conținutul într-un folder pe calculatorul local (de exemplu, pe Desktop).

---

## Pasul 1: Configurarea permisiunilor PowerShell

Pentru a rula scripturile de instalare, trebuie să setăm o politică de execuție mai permisivă.

1. Deschideți un **Terminal (PowerShell)** cu drepturi de **Administrator** în folderul în care a fost descărcat kitul de instalare.
2. Rulați următoarea comandă:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
   ```
3. *Notă: După finalizarea tuturor pașilor de instalare, puteți reveni la politica implicită dacă doriți.*

## Pasul 2: Instalarea Kit-ului (Partea I)

Rămâneți în **Terminalul (PowerShell)** cu drepturi de **Administrator** (deschis în folderul kitului) și lansați scriptul principal de instalare:

```powershell
.\install.ps1
```

Acest script va instala:
- WSL 2
- Docker Desktop
- VS Code și extensiile necesare

## Pasul 3: Repornirea sistemului

1. **Reporniți calculatorul.**
2. După repornire, autentificați-vă cu același utilizator (cel al elevului).
3. Așteptați ca **Docker Desktop** să pornească automat.
4. Dacă apare fereastra de login pentru Docker, apăsați butonul **"Skip login"**.

## Pasul 4: Finalizarea instalării (Partea II)

După ce Docker este funcțional, deschideți un **Terminal (PowerShell)** în folderul kitului (nu este necesar Admin de data aceasta, dar este permis) și rulați scriptul de post-instalare:

```powershell
.\post-install.ps1
```

Acest pas va:
- Descărca imaginea Docker pentru Jupyter.
- Crea folderul `ONIA` pe Desktop.
- Genera fișierul `jupyter_connection.txt` cu datele de conectare.

---

# Administrarea accesului la Internet (În ziua concursului)

Aceste acțiuni se efectuează de către administratori pentru a securiza mediul de concurs.

### Înainte de începerea competiției
Pentru a restricționa accesul la internet, rulați scriptul `restrict.bat` cu drepturi de **Administrator**. 
- Când sunteți întrebat (prompt), răspundeți cu `y` (Yes).

### După finalizarea competiției
Pentru a restaura accesul complet la internet, rulați din nou scriptul `restrict.bat` cu drepturi de **Administrator**.
- Când sunteți întrebat (prompt), răspundeți cu `n` (No).

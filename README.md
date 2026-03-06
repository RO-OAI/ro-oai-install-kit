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
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
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

### ⚠️ Depanare: Dacă instalarea eșuează la activarea WSL sau Docker

Dacă scriptul `install.ps1` raportează erori legate de "Virtual Machine Platform" sau Docker nu pornește, este foarte probabil ca **virtualizarea să fie dezactivată din BIOS**.

**Cum verificați:**
1. Deschideți **Task Manager** (Ctrl+Shift+Esc).
2. Mergeți la tab-ul **Performance** și selectați **CPU**.
3. În partea dreaptă-jos, căutați **Virtualization**.
   - Dacă scrie **Enabled**, virtualizarea este activă.
   - Dacă scrie **Disabled**, trebuie activată din BIOS/UEFI.

**Cum activați în BIOS:**
- Reporniți calculatorul și intrați în setările BIOS/UEFI (de regulă apăsând F2, F10, F12 sau Del la pornire).
- Căutați și activați (setați pe **Enabled**):
  - **Intel VT-x** sau **Intel Virtualization Technology** (pentru procesoare Intel).
  - **AMD-V** sau **SVM Mode** (pentru procesoare AMD).
- Salvați și ieșiți (F10), apoi reîncercați instalarea.

## Pasul 3: Repornirea sistemului

1. **Reporniți calculatorul.**
2. După repornire, autentificați-vă cu același utilizator (cel al elevului).
3. Așteptați ca **Docker Desktop** să pornească automat. Daca nu porneste automat, porniti manual din meniul Start sau de pe Desktop.
4. Dacă apare fereastra de login pentru Docker, apăsați butonul **"Skip login"**.

## Pasul 4: Finalizarea instalării (Partea II)

După ce Docker este funcțional, deschideți un **Terminal (PowerShell)** în folderul kitului (este important sa NU fie ca Administrator) și rulați scriptul de post-instalare:

```powershell
.\post-install.ps1
```

Acest pas va:
- Descărca imaginea Docker pentru Jupyter.
- Crea folderul `ONIA` pe Desktop.
- Genera fișierul `README.md` cu datele de conectare și link-ul platformei.
- Crea scurtăturile `Open_Jupyter.url`, `Platforma_OAI.url` și `Open_in_VSCode.lnk` pentru acces rapid.

## Pasul 5: Verificarea Instalării

Pentru a te asigura că totul este configurat corect, urmează acești pași:

### A. Verificare Jupyter
1. Navighează pe **Desktop** și deschide folderul **ONIA**.
2. Identifică și deschide fișierul (scurtătura) numit **"Open_Jupyter.url"**. Aceasta va deschide interfața Jupyter în browserul tău.
3. În interfața Jupyter, caută și deschide notebook-ul **`test_imports.ipynb`**.
4. Rulează celulele din notebook (apasă **Shift + Enter** pe fiecare celulă sau butonul **Run** de sus).
5. Dacă toate celulele rulează fără erori, înseamnă că mediul de lucru este pregătit pentru concurs!

### B. Verificare VS Code (Opțional)
Dacă preferi să lucrezi în VS Code, urmează acești pași pentru a-l conecta la mediul de concurs:
1. Din folderul **ONIA** de pe Desktop, deschide scurtătura **"Open_in_VSCode.lnk"**.
2. Deschide fișierul `test_imports.ipynb` în VS Code.
3. Dacă ți se cere să selectezi un kernel (sus în dreapta):
   - Apasă pe **Select Kernel**.
   - Alege **Existing Jupyter Server...**.
   - Introdu adresa URL a serverului Jupyter (o găsești în fișierul `README.md` din folderul **ONIA**, de forma `http://localhost:8888/?token=...`).
   - După conectare, selectează kernel-ul **Python 3 (ipykernel)**.
4. Rulează celulele pentru a confirma că totul funcționează.

---

# Administrarea accesului la Internet (În ziua concursului)

Aceste acțiuni se efectuează de către administratori pentru a securiza mediul de concurs.

### Înainte de începerea competiției
Pentru a restricționa accesul la internet, rulați scriptul `restrict.bat` cu drepturi de **Administrator**. 
- Când sunteți întrebat (prompt), răspundeți cu `y` (Yes).

### După finalizarea competiției
Pentru a restaura accesul complet la internet, rulați din nou scriptul `restrict.bat` cu drepturi de **Administrator**.
- Când sunteți întrebat (prompt), răspundeți cu `n` (No).

# Întrebări Frecvente (FAQ) - Instalare și Configurare Mediu de Lucru

Soluții pentru cele mai frecvente situații întâlnite în timpul configurării mediului de concurs.

---

### 1. Ce fac dacă Docker Desktop nu pornește automat după restart?
**Întrebare:** Am ajuns la pasul 3, dar după repornirea calculatorului și reconectarea pe contul de elev, Docker Desktop nu pornește automat. Pe contul de administrator funcționează. Ce ar trebui să fac?

**Răspuns:** Dacă Docker Desktop nu pornește automat, acesta trebuie **lansat manual** din meniul Start sau de pe Desktop. Deși în mod normal procesul este automatizat, pornirea manuală a aplicației rezolvă problemele de acces la serverul local constatate în timpul simulărilor.

---

### 2. Cum procedez cu alerta de securitate Windows (Firewall)?
**Întrebare:** Îmi apare un mesaj de la Windows Security care mă întreabă dacă permit accesul rețelelor publice și private pentru "Docker Desktop Backend". Ce opțiune aleg?

**Răspuns:** Recomandăm să selectați **Cancel** (Anulare). Totuși, dacă ați apăsat deja pe **Allow** (Permite), nu se va întâmpla nimic neobișnuit și mediul de lucru va funcționa corect în continuare.

---

### 3. De ce nu a apărut folderul "ONIA" pe desktop-ul utilizatorului de elev?
**Întrebare:** Am rulat scriptul, dar folderul ONIA nu a fost creat pe desktop-ul de elev, ci pe cel de administrator. Cum procedez?

**Răspuns:** Scriptul de post-instalare **NU trebuie rulat ca administrator**. Dacă este rulat cu "Run as administrator", sistemul va crea fișierele în profilul administratorului. 
* **Soluție:** Rulați scriptul direct de pe utilizatorul de elev, prin dublu-click normal, pentru ca scurtăturile și folderele să apară corect pe desktop-ul de lucru.

---

### 4. Ce kernel trebuie să selectez în Jupyter Notebook / VS Code?
**Întrebare:** La deschiderea fișierului `test_imports.ipynb`, sistemul îmi cere să selectez un kernel. Ce aleg?

**Răspuns:** Trebuie să selectați opțiunea **Python 3 (ipykernel)** din lista derulantă și apoi să apăsați butonul **Select**. După acest pas, ar trebui să vedeți mesajul "All imports working!".

---

### 5. Eroare în VS Code: "The editor could not be opened because the file was not found"
**Întrebare:** Am lansat VS Code și primesc o eroare care spune că fișierul SQL nu a fost găsit. Cum rezolv?

**Răspuns:** Această eroare apare dacă editorul încearcă să redeschidă un fișier dintr-o locație care nu mai este validă (de exemplu, direct dintr-o arhivă .zip sau o cale temporară de admin). 
* **Soluție:** Folosiți opțiunea **File > Open Folder** din VS Code și selectați folderul **ONIA** aflat pe desktop-ul utilizatorului curent.

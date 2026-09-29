# JAGO Deployment Guide — Student Mobile App & Backend

This guide walks you through deploying the **JAGO Student Mobile App** and its supporting **FastAPI Backend**.

---

## 🔍 Why `https://jago-lovat.vercel.app` Looked Like an Admin Website

Previously, your Vercel deployment was serving the **React Admin Dashboard** instead of the **Student Mobile App**:
1. The root `package.json` was set to run `vite build`, which compiles the admin portal into `dist/`.
2. Vercel was configured to serve `dist/`, so visitors saw the government desktop portal instead of the mobile app.

The **Flutter Student Mobile App** has its own production web build located in:
```
mobile_app/build/web/
```

Follow the steps below to deploy both the Backend and the Student Mobile App.

---

## 🚀 Step 1: Deploy the FastAPI Backend (Free on Render.com)

The student app needs a live cloud backend to register users, verify OTPs, and fetch scholarship statuses.

### Deploying on Render (Free & 3 Minutes):
1. Sign up / Log in to [Render.com](https://render.com).
2. Click **New +** and select **Web Service**.
3. Connect your GitHub repository (`Vocalforlocals/JAGO`).
4. Configure the settings:
   - **Name:** `jago-backend`
   - **Root Directory:** `backend`
   - **Runtime:** `Python 3` (or choose `Docker`)
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Instance Type:** `Free`
5. Click **Advanced** and add Environment Variables:
   | Key | Value |
   |---|---|
   | `SECRET_KEY` | `jago_production_secret_key_2026` |
   | `ALLOWED_ORIGINS` | `*` |
   | `SEED_DEMO_DATA` | `true` |
6. Click **Deploy Web Service**.
7. Once deployed, copy your live backend URL (e.g. `https://jago-backend.onrender.com`).
8. Test your backend by opening:
   ```
   https://jago-backend.onrender.com/health
   ```
   It should return: `{"status": "healthy", "service": "JAGO Unified Scholarship Engine", ...}`

---

## 🌐 Step 2: Deploy the Student Mobile App to Vercel

The Student Mobile App has already been pre-compiled to `mobile_app/build/web/` with routing rules configured (`vercel.json`).

### Method A: Instant Deployment via Vercel CLI (Recommended — 60 Seconds)

1. Open PowerShell or Terminal in your project root:
   ```powershell
   cd C:\Users\bhask\Desktop\Workspace\Jago\mobile_app\build\web
   ```

2. Run the deployment command:
   ```powershell
   npx vercel --prod
   ```

3. Follow the short interactive prompts:
   - **Set up and deploy?** -> `y`
   - **Which scope?** -> (Select your account / team)
   - **Link to existing project?** -> `y`
   - **What's the name of the existing project?** -> `jago-lovat` (or your preferred project name)
   - **In which directory is your code located?** -> `./`

4. Vercel will upload the pre-built Flutter Student Mobile App immediately!
   Once complete, open `https://jago-lovat.vercel.app/` and you will see the **JAGO Student Mobile App** loaded in its 6.7" smartphone chassis!

---

### Method B: Deploying via GitHub on Vercel

If you prefer Vercel to automatically deploy on git pushes:

1. Open your project on [vercel.com](https://vercel.com).
2. Go to **Settings** -> **General**.
3. Scroll down to **Root Directory**:
   - Click **Edit**.
   - Change root directory to: `mobile_app/build/web`
   - Click **Save**.
4. Scroll to **Build & Development Settings**:
   - Toggle **Override** on **Build Command** and leave it blank (empty).
   - Toggle **Override** on **Output Directory** and set it to: `.`
   - Click **Save**.
5. Go to the **Deployments** tab and click **Redeploy** on the latest deployment.

---

## 📱 Step 3: Build the Android Mobile App (.APK)

If you want a real `.apk` installer to download and install on any physical Android smartphone:

1. Open terminal in `mobile_app/`:
   ```powershell
   cd C:\Users\bhask\Desktop\Workspace\Jago\mobile_app
   ```

2. Build the optimized Release APK:
   ```powershell
   # If pointing to a hosted backend:
   flutter build apk --release --dart-define=API_URL=https://jago-backend.onrender.com/api

   # Or standard build:
   flutter build apk --release
   ```

3. The compiled APK is saved at:
   ```
   mobile_app/build/app/outputs/flutter-apk/app-release.apk
   ```

4. Transfer this `.apk` to your phone via:
   - Google Drive / OneDrive download link
   - WhatsApp Web / Telegram Saved Messages
   - USB Cable (Direct File Transfer)
5. Tap on the file on your phone, choose **Install**, and launch the native JAGO app!

---

## 🐳 Step 4: Full Stack Local Deployment (Docker)

To run the entire system locally with one command (PostgreSQL + FastAPI + Admin Dashboard + Student App):
```powershell
cd C:\Users\bhask\Desktop\Workspace\Jago
docker compose up --build -d
```
- Student App (served via web): `http://localhost:3000`
- FastAPI Documentation: `http://localhost:8000/docs`
- Officer Admin Portal: `http://localhost:5173`

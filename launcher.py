import os
import sys
import json
import time
import urllib.request
import urllib.error
import subprocess
import ctypes

def msg_box(title, text, style=0):
    ctypes.windll.user32.MessageBoxW(0, text, title, style)

def check_ollama():
    url = "http://127.0.0.1:11434/api/tags"
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=3) as response:
            data = json.loads(response.read().decode('utf-8'))
            models = data.get("models", [])
            for m in models:
                name = m.get("name", "")
                if name == "gemma2:2b" or name.startswith("gemma2:2b:"):
                    return True
            
            # Model not found
            msg_box("Missing Model", 
                    "Ollama is running, but the 'gemma2:2b' model is not installed.\n\n"
                    "Please open your terminal (Command Prompt or PowerShell) and run:\n"
                    "ollama run gemma2:2b\n\n"
                    "Once the model is downloaded, you can use Niji LOCAL.", 0x30)
            return False
    except urllib.error.URLError:
        msg_box("Ollama Not Found", 
                "Ollama is not running or not installed.\n\n"
                "Niji LOCAL requires Ollama for private AI analysis.\n"
                "Please download and install it from https://ollama.com\n\n"
                "After installing, run 'ollama run gemma2:2b' in your terminal.", 0x10)
        return False
    except Exception as e:
        msg_box("Error", f"An error occurred checking Ollama: {str(e)}", 0x10)
        return False

def check_backend_running():
    url = "http://127.0.0.1:8000/api/settings/serpapi/status"
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=2) as response:
            data = json.loads(response.read().decode('utf-8'))
            if "status" in data:
                return True
    except Exception:
        pass
    return False

def wait_for_backend(timeout=15):
    start = time.time()
    while time.time() - start < timeout:
        if check_backend_running():
            return True
        time.sleep(1)
    return False

def main():
    if not check_ollama():
        # Do not block the app, but they've been warned.
        # Actually, let's just proceed so they can still browse the UI, or exit?
        # The prompt says: "Gives clear setup instructions if either is missing"
        # We did. Let's proceed, as they can import CSVs and do non-AI tasks.
        pass

    backend_exe = os.path.join(os.path.dirname(sys.executable), "backend", "run_server.exe")
    frontend_exe = os.path.join(os.path.dirname(sys.executable), "frontend", "frontend.exe")
    
    # In development, fallback to paths relative to launcher.py
    if not getattr(sys, 'frozen', False):
        backend_exe = os.path.join(os.path.dirname(__file__), "backend", "dist", "run_server", "run_server.exe")
        frontend_exe = os.path.join(os.path.dirname(__file__), "frontend", "build", "windows", "x64", "runner", "Release", "frontend.exe")

    # Start backend if not already running
    backend_proc = None
    if not check_backend_running():
        if os.path.exists(backend_exe):
            # CREATE_NO_WINDOW = 0x08000000
            backend_proc = subprocess.Popen([backend_exe], creationflags=0x08000000)
        else:
            # If we're running from python source without dist
            py_exe = sys.executable
            run_py = os.path.join(os.path.dirname(__file__), "backend", "run_server.py")
            if os.path.exists(run_py):
                backend_proc = subprocess.Popen([py_exe, run_py], creationflags=0x08000000)
            else:
                msg_box("Backend Not Found", f"Cannot find backend executable at {backend_exe}", 0x10)
                sys.exit(1)

        if not wait_for_backend():
            msg_box("Backend Failed", "The backend server failed to start within the timeout.", 0x10)
            if backend_proc:
                backend_proc.terminate()
            sys.exit(1)

    # Start frontend
    if os.path.exists(frontend_exe):
        subprocess.Popen([frontend_exe])
    else:
        msg_box("Frontend Not Found", f"Cannot find frontend executable at {frontend_exe}", 0x10)
        
if __name__ == "__main__":
    main()

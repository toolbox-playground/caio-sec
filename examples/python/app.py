# =============================================================================
# ⚠️  ARQUIVO PROPOSITALMENTE VULNERÁVEL - APENAS PARA FINS DIDÁTICOS  ⚠️
# =============================================================================
# Este arquivo contém vulnerabilidades INTENCIONAIS para demonstrar como
# ferramentas de segurança (Snyk, Trivy, Checkov) detectam problemas reais.
#
# NÃO USE ESTE CÓDIGO EM PRODUÇÃO!
# NÃO USE ESTES VALORES DE SEGREDOS EM PRODUÇÃO!
#
# Vulnerabilidades presentes:
#   1. Segredos hardcoded (API keys, senhas, tokens)
#   2. SQL Injection
#   3. Criptografia fraca (MD5)
#   4. Input não sanitizado
#   5. Debug mode habilitado
#   6. Dependências vulneráveis (ver requirements.txt)
# =============================================================================

from flask import Flask, request, jsonify
import sqlite3
import hashlib
import os

# ⚠️ VULNERABILIDADE #1: Segredos hardcoded diretamente no código
# Ferramentas que detectam: Gitleaks, TruffleHog, Snyk Code
SECRET_KEY = "super-secret-key-12345"
API_KEY = "sk-proj-abc123xyz456def789"
DATABASE_PASSWORD = "admin123"
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
STRIPE_KEY = "sk_live_4eC39HqLyjWDarjtT1zdp7dc"

app = Flask(__name__)

# ⚠️ VULNERABILIDADE #2: Debug mode habilitado em produção
# Permite execução remota de código (RCE) se explorado
app.config['DEBUG'] = True
app.config['SECRET_KEY'] = SECRET_KEY

# Inicializa banco de dados SQLite (apenas para exemplo)
def init_db():
    """Inicializa o banco de dados com dados de exemplo."""
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            username TEXT,
            password TEXT,
            email TEXT
        )
    ''')
    # ⚠️ Senha hardcoded no código (outra vulnerabilidade)
    cursor.execute(
        "INSERT OR IGNORE INTO users VALUES (1, 'admin', 'admin123', 'admin@example.com')"
    )
    conn.commit()
    conn.close()


@app.route('/login', methods=['POST'])
def login():
    """
    ⚠️ VULNERABILIDADE #3: SQL Injection
    O input do usuário é inserido diretamente na query SQL sem sanitização.
    Atacante pode usar: username = "' OR '1'='1" para burlar autenticação.
    Ferramenta que detecta: Snyk Code, Checkov
    """
    username = request.form.get('username', '')
    password = request.form.get('password', '')

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # ⚠️ SQL INJECTION: Nunca faça assim! Use parâmetros (?) ao invés de f-string
    query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    cursor.execute(query)

    user = cursor.fetchone()
    conn.close()

    if user:
        return jsonify({'status': 'success', 'user': user[1]})
    return jsonify({'status': 'error', 'message': 'Credenciais inválidas'}), 401


@app.route('/hash', methods=['GET'])
def hash_password():
    """
    ⚠️ VULNERABILIDADE #4: Uso de MD5 para hash de senhas
    MD5 é considerada insegura para hashing de senhas.
    Use bcrypt, argon2 ou PBKDF2 ao invés disso.
    Ferramenta que detecta: Snyk Code, Checkov
    """
    password = request.args.get('password', '')

    # ⚠️ CRIPTOGRAFIA FRACA: MD5 não é adequado para senhas
    hashed = hashlib.md5(password.encode()).hexdigest()

    return jsonify({'hash': hashed, 'algorithm': 'md5 (INSEGURO!)'})


@app.route('/execute', methods=['POST'])
def execute_command():
    """
    ⚠️ VULNERABILIDADE #5: Command Injection / OS Command Injection
    Nunca execute comandos do sistema operacional com input do usuário.
    Atacante pode usar: command = "ls; rm -rf /" para executar código malicioso.
    Ferramenta que detecta: Snyk Code, Checkov
    """
    command = request.json.get('command', '')

    # ⚠️ COMMAND INJECTION: Nunca faça isso!
    result = os.popen(command).read()

    return jsonify({'output': result})


@app.route('/users', methods=['GET'])
def list_users():
    """
    Lista todos os usuários - sem autenticação e sem paginação.
    ⚠️ VULNERABILIDADE #6: Ausência de autenticação e exposição de dados sensíveis
    """
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    # Retorna TODOS os dados incluindo senhas (plaintext!)
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    conn.close()

    # ⚠️ Expõe senhas em plaintext na API
    return jsonify({'users': users})


@app.route('/health', methods=['GET'])
def health():
    """Endpoint de health check - seguro."""
    return jsonify({'status': 'ok', 'version': '1.0.0'})


if __name__ == '__main__':
    init_db()
    # ⚠️ VULNERABILIDADE #7: Bind em 0.0.0.0 expõe a todas as interfaces de rede
    app.run(host='0.0.0.0', port=5000, debug=True)

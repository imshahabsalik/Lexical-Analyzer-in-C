import sys
import os
import subprocess
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


# ---------------- WORKER THREAD ----------------
class LexerWorker(QThread):
    finished = pyqtSignal(str)

    def __init__(self, lexer_path, base_dir, input_path, output_path):
        super().__init__()
        self.lexer_path = lexer_path
        self.base_dir = base_dir
        self.input_path = input_path
        self.output_path = output_path

    def run(self):
        try:
            result = subprocess.run(
                [self.lexer_path],
                cwd=self.base_dir,
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                self.finished.emit(
                    f"Return Code: {result.returncode}\n{result.stderr}"
                )
                return

            if not os.path.exists(self.output_path):
                self.finished.emit("tokens.txt not generated")
                return

            with open(self.output_path, "r", encoding="utf-8") as f:
                data = f.read()

            self.finished.emit(data)

        except Exception as e:
            self.finished.emit(str(e))


# ---------------- MAIN APP ----------------
class LexerApp(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("C-Lex Analyzer")
        self.setGeometry(100, 100, 1200, 750)

        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.lexer_path = os.path.join(self.base_dir, "lexer.exe")
        self.input_path = os.path.join(self.base_dir, "input.c")
        self.output_path = os.path.join(self.base_dir, "tokens.txt")

        self.auto_mode = False
        self.user_started = False

        self.timer = QTimer()
        self.timer.setInterval(700)
        self.timer.timeout.connect(self.execute_lexer)

        self.init_ui()

    def init_ui(self):
        main = QWidget()
        self.setCentralWidget(main)

        layout = QHBoxLayout()

        # Sidebar
        sidebar = QVBoxLayout()

        btn_run = QPushButton("Analyze")
        btn_run.clicked.connect(self.run_clicked)

        btn_load = QPushButton("Load File")
        btn_load.clicked.connect(self.load_file)

        btn_clear = QPushButton("Clear")
        btn_clear.clicked.connect(self.clear_all)

        sidebar.addWidget(btn_run)
        sidebar.addWidget(btn_load)
        sidebar.addWidget(btn_clear)
        sidebar.addStretch()

        # Editor
        self.editor = QPlainTextEdit()
        self.editor.setFont(QFont("Consolas", 14))
        self.editor.textChanged.connect(self.on_text_changed)

        # Output tabs
        tabs = QTabWidget()

        self.tokens = QTextEdit()
        self.symbols = QTextEdit()
        self.stats = QTextEdit()

        for w in [self.tokens, self.symbols, self.stats]:
            w.setFont(QFont("Consolas", 12))

        tabs.addTab(self.tokens, "Tokens")
        tabs.addTab(self.symbols, "Symbol Table")
        tabs.addTab(self.stats, "Statistics")

        right = QVBoxLayout()
        right.addWidget(self.editor, 3)
        right.addWidget(tabs, 2)

        layout.addLayout(sidebar, 1)
        layout.addLayout(right, 4)

        main.setLayout(layout)

        # Dark theme
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QPlainTextEdit, QTextEdit {
                background-color: #1e1e1e;
                color: #d4d4d4;
                padding: 10px;
                border: none;
            }
            QPushButton {
                background-color: #2d2d2d;
                color: white;
                padding: 8px;
            }
            QPushButton:hover {
                background-color: #007acc;
            }
        """)

    # ---------------- BUTTON ----------------
    def run_clicked(self):
        self.user_started = True
        self.auto_mode = True
        self.execute_lexer()

    # ---------------- LIVE ANALYSIS ----------------
    def on_text_changed(self):
        if not self.auto_mode or not self.user_started:
            return

        self.timer.stop()
        self.timer.start()

    # ---------------- EXECUTION ----------------
    def execute_lexer(self):
        code = self.editor.toPlainText().strip()
        if not code:
            return

        with open(self.input_path, "w", encoding="utf-8") as f:
            f.write(code)

        self.worker = LexerWorker(
            self.lexer_path,
            self.base_dir,
            self.input_path,
            self.output_path
        )

        self.worker.finished.connect(self.display_output)
        self.worker.start()

    # ---------------- DISPLAY ----------------
    def display_output(self, data):
        
        scrollbar = self.tokens.verticalScrollBar()

        
        old_value = scrollbar.value()
        old_max = scrollbar.maximum()

        self.tokens.blockSignals(True)   # prevent flicker
        self.tokens.clear()
        self.symbols.clear()
        self.stats.clear()

        section = "tokens"

        for line in data.splitlines():
            if "SYMBOL TABLE" in line:
                section = "symbol"
                continue
            elif "TOKEN STATISTICS" in line:
                section = "stats"
                continue

            if section == "tokens":
                self.append_colored(line)
            elif section == "symbol":
                self.symbols.append(line)
            else:
                self.stats.append(line)

        self.tokens.blockSignals(False)

        
        new_max = scrollbar.maximum()

        if old_value < old_max:  
            
            scrollbar.setValue(old_value)
        else:
            # user was at bottom → keep auto-scroll
            scrollbar.setValue(new_max)

    # ---------------- COLOR OUTPUT ----------------
    def append_colored(self, text):
        scrollbar = self.tokens.verticalScrollBar()

        # Check if user is at bottom
        at_bottom = scrollbar.value() == scrollbar.maximum()

        cursor = self.tokens.textCursor()
        format = QTextCharFormat()

        if "ERROR" in text:
            format.setForeground(QColor("#ff4d4d"))
        elif "KEYWORD" in text:
            format.setForeground(QColor("#4da6ff"))
        elif "IDENTIFIER" in text:
            format.setForeground(QColor("#ffffff"))
        elif "OPERATOR" in text:
            format.setForeground(QColor("#ffa500"))
        elif "CONSTANT" in text or "FLOAT" in text:
            format.setForeground(QColor("#00ffcc"))
        elif "STRING" in text:
            format.setForeground(QColor("#00ff00"))
        elif "CHAR" in text:
            format.setForeground(QColor("#66ff66"))
        else:
            format.setForeground(QColor("#cccccc"))

        cursor.movePosition(QTextCursor.End)
        cursor.insertText(text + "\n", format)

        # Restore scroll position
        if at_bottom:
            scrollbar.setValue(scrollbar.maximum())

    # ---------------- LOAD FILE ----------------
    def load_file(self):
        path, _ = QFileDialog.getOpenFileName(self, "Open File", "", "C Files (*.c)")
        if path:
            with open(path, "r", encoding="utf-8") as f:
                self.editor.setPlainText(f.read())

        self.user_started = True
        self.auto_mode = True

    # ---------------- CLEAR ----------------
    def clear_all(self):
        self.editor.clear()
        self.tokens.clear()
        self.symbols.clear()
        self.stats.clear()
        self.auto_mode = False
        self.user_started = False


# ---------------- RUN ----------------
app = QApplication(sys.argv)
window = LexerApp()
window.show()
sys.exit(app.exec_())
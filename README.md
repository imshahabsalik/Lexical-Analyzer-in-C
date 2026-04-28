# 🚀 C-Lex: A C Lexical Analyzer

## 📌 Overview

C-Lex is a lexical analyzer for the C programming language built using **Flex** and integrated with a **PyQt5 GUI**.
It tokenizes source code, detects errors, and displays structured output in real-time.

---

## ✨ Features

* Token generation (keywords, identifiers, constants, operators, separators)
* Supports:

  * Integer, float, hex, octal, scientific numbers
  * Strings & characters with escape sequences
* Comment handling (`//`, `/* */`)
* Preprocessor detection (`#include`, etc.)
* Symbol table generation
* Token statistics
* Error detection (invalid tokens, unclosed strings, etc.)
* Real-time GUI with syntax highlighting

---

## 🛠️ Tech Stack

* **Python (PyQt5)** – GUI
* **Flex (Lex)** – Lexical analysis
* **C (GCC)** – Compilation
* **subprocess + QThread** – Integration & performance

---

## ⚙️ How to Run

```bash
flex lexer.l
gcc lex.yy.c -o lexer.exe
python app.py
```

---

## 📊 Sample Output

```
LINE | LEXEME         | TOKEN
----------------------------------------
1    | int            | KEYWORD
1    | a              | IDENTIFIER
1    | =              | OPERATOR
1    | 10             | CONSTANT
```

---

## 🧠 Key Concepts

* Lexical Analysis
* Regular Expressions
* Symbol Table
* Compiler Design Basics

---

## 🏆 Conclusion

C-Lex demonstrates a near-complete implementation of lexical analysis for C, combining compiler design concepts with a modern GUI interface for real-time interaction.

---

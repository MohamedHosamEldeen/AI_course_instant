import tkinter as tk
from tkinter import messagebox, ttk
from abc import ABC, abstractmethod


# ================= COLORS =================

BG = "#f5f6fa"
SIDEBAR = "#1f2937"
SIDEBAR_HOVER = "#374151"
PRIMARY = "#4f46e5"
DANGER = "#ef4444"
SUCCESS = "#22c55e"
WARNING = "#f59e0b"
TEXT = "white"


# ================= OOP =================

class Person(ABC):
    def __init__(self, name, age, code):
        self.name = name
        self.age = age
        
        self.code = code

    @abstractmethod
    def display(self):
        pass


class Student(Person):
    def __init__(self, name, age, code, gpa, hours, subjects, department):
        super().__init__(name, age, code)
        self.gpa = gpa
        self.hours = hours
        self.subjects = subjects
        self.department = department

    def display(self):
        return (self.code, self.name, self.gpa, self.department)


class Doctor(Person):
    def __init__(self, name, age, code, subject, department, salary):
        super().__init__(name, age, code)
        self.subject = subject
        self.department = department
        self.salary = salary

    def display(self):
        return (self.code, self.name, self.subject, self.department, self.salary)


class Subject:
    def __init__(self, name, code, hours):
        self.name = name
        self.code = code
        self.hours = hours

    def display(self):
        return (self.code, self.name, self.hours)


# ================= DATABASE =================

class Database:
    def __init__(self):
        self.people = []
        self.subjects = []
        self.trash = []

    def add_person(self, p):
        self.people.append(p)

    def add_subject(self, s):
        self.subjects.append(s)

    def delete(self, code):
        for i in self.people:
            if i.code == code:
                self.people.remove(i)
                self.trash.append(i)
                return

        for i in self.subjects:
            if i.code == code:
                self.subjects.remove(i)
                self.trash.append(i)
                return

    def restore(self, code):
        for i in self.trash:
            if i.code == code:
                self.trash.remove(i)

                if isinstance(i, Subject):
                    self.subjects.append(i)
                else:
                    self.people.append(i)
                return

    def update_person(self, code, obj):
        for i in range(len(self.people)):
            if self.people[i].code == code:
                self.people[i] = obj

    def update_subject(self, code, obj):
        for i in range(len(self.subjects)):
            if self.subjects[i].code == code:
                self.subjects[i] = obj


# ================= UI =================

class AppGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("University System Pro")
        self.root.geometry("1100x650")
        self.root.configure(bg=BG)

        self.db = Database()
        self.mode = "student"
        self.selected_code = None

        # LEFT
        self.left = tk.Frame(root, bg=SIDEBAR, width=220)
        self.left.pack(side="left", fill="y")

        self.right = tk.Frame(root, bg=BG)
        self.right.pack(side="right", fill="both", expand=True)

        tk.Label(self.left, text="🎓 SYSTEM",
                 bg=SIDEBAR, fg="white",
                 font=("Arial", 18, "bold")).pack(pady=20)

        def hover(btn):
            btn.bind("<Enter>", lambda e: btn.config(bg=SIDEBAR_HOVER))
            btn.bind("<Leave>", lambda e: btn.config(bg=SIDEBAR))

        def nav(text, cmd):
            b = tk.Button(self.left, text=text,
                          bg=SIDEBAR, fg="white",
                          font=("Arial", 13, "bold"),
                          bd=0, pady=12, anchor="w",
                          command=cmd)
            b.pack(fill="x")
            hover(b)

        nav("📚 Students", lambda: self.switch("student"))
        nav("👨‍🏫 Doctors", lambda: self.switch("doctor"))
        nav("📖 Subjects", lambda: self.switch("subject"))

        tk.Button(self.left, text="🗑 Trash",
                  bg=DANGER, fg="white",
                  font=("Arial", 12, "bold"),
                  bd=0, pady=10,
                  command=self.open_trash).pack(fill="x", pady=20)

        # TITLE
        self.title = tk.Label(self.right, text="",
                              font=("Arial", 24, "bold"),
                              bg=BG)
        self.title.pack(pady=10)

        # FORM
        self.form = tk.Frame(self.right, bg=BG)
        self.form.pack()

        self.btns = tk.Frame(self.right, bg=BG)
        self.btns.pack(pady=10)

        self.tree = ttk.Treeview(self.right)
        self.tree.pack(fill="both", expand=True)
        self.tree.bind("<<TreeviewSelect>>", self.select_row)

        self.entries = {}

        self.build_student()

    # ================= FORM =================

    def clear(self):
        for w in self.form.winfo_children():
            w.destroy()
        for w in self.btns.winfo_children():
            w.destroy()
        self.entries = {}
        self.selected_code = None

    def field(self, name, i):
        tk.Label(self.form, text=name, bg=BG).grid(row=i, column=0, padx=5, pady=3)
        e = tk.Entry(self.form, width=25)
        e.grid(row=i, column=1, padx=5, pady=3)
        self.entries[name] = e

    # ================= VIEWS =================

    def build_student(self):
        self.clear()
        self.mode = "student"
        self.title.config(text="Students")

        for i, f in enumerate(["Name","Age","Code","GPA","Hours","Subjects","Department"]):
            self.field(f, i)

        self.buttons()
        self.table(["Code","Name","GPA","Department"])

    def build_doctor(self):
        self.clear()
        self.mode = "doctor"
        self.title.config(text="Doctors")

        for i, f in enumerate(["Name","Age","Code","Subject","Department","Salary"]):
            self.field(f, i)

        self.buttons()
        self.table(["Code","Name","Subject","Department","Salary"])

    def build_subject(self):
        self.clear()
        self.mode = "subject"
        self.title.config(text="Subjects")

        for i, f in enumerate(["Name","Code","Hours"]):
            self.field(f, i)

        self.buttons()
        self.table(["Code","Name","Hours"])

    # ================= BUTTON STYLE =================

    def btn(self, text, color, cmd):
        return tk.Button(self.btns, text=text,
                          bg=color, fg="white",
                          font=("Arial", 11, "bold"),
                          bd=0, padx=10, pady=5,
                          command=cmd)

    def buttons(self):
        self.btn("➕ Add", SUCCESS, self.add).grid(row=0, column=0, padx=5)
        self.btn("🗑 Delete", DANGER, self.delete_selected).grid(row=0, column=1, padx=5)
        self.btn("👁 View", PRIMARY, self.view).grid(row=0, column=2, padx=5)
        self.btn("✏ Edit", WARNING, self.edit).grid(row=0, column=3, padx=5)

    # ================= TABLE =================

    def table(self, cols):
        self.tree.delete(*self.tree.get_children())
        self.tree["columns"] = cols
        self.tree["show"] = "headings"

        for c in cols:
            self.tree.heading(c, text=c)
            self.tree.column(c, width=140)

    # ================= ADD =================

    def add(self):
        d = {k: v.get() for k, v in self.entries.items()}

        if self.mode == "student":
            self.db.add_person(Student(d["Name"], int(d["Age"]), d["Code"],
                                       float(d["GPA"]), int(d["Hours"]),
                                       d["Subjects"], d["Department"]))

        elif self.mode == "doctor":
            self.db.add_person(Doctor(d["Name"], int(d["Age"]), d["Code"],
                                      d["Subject"], d["Department"], float(d["Salary"])))

        else:
            self.db.add_subject(Subject(d["Name"], d["Code"], int(d["Hours"])))

        self.view()

    # ================= VIEW =================

    def view(self):
        self.tree.delete(*self.tree.get_children())

        if self.mode == "student":
            for p in self.db.people:
                if isinstance(p, Student):
                    self.tree.insert("", "end", values=p.display())

        elif self.mode == "doctor":
            for p in self.db.people:
                if isinstance(p, Doctor):
                    self.tree.insert("", "end", values=p.display())

        else:
            for s in self.db.subjects:
                self.tree.insert("", "end", values=s.display())

    # ================= SELECT =================

    def select_row(self, event):
        row = self.tree.focus()
        val = self.tree.item(row, "values")

        if val:
            self.selected_code = val[0]

    # ================= DELETE =================

    def delete_selected(self):
        if self.selected_code:
            self.db.delete(self.selected_code)
            self.view()

    # ================= EDIT =================

    def edit(self):
        if not self.selected_code:
            return

        d = {k: v.get() for k, v in self.entries.items()}

        if self.mode == "student":
            obj = Student(d["Name"], int(d["Age"]), d["Code"],
                          float(d["GPA"]), int(d["Hours"]),
                          d["Subjects"], d["Department"])
            self.db.update_person(self.selected_code, obj)

        elif self.mode == "doctor":
            obj = Doctor(d["Name"], int(d["Age"]), d["Code"],
                         d["Subject"], d["Department"], float(d["Salary"]))
            self.db.update_person(self.selected_code, obj)

        else:
            obj = Subject(d["Name"], d["Code"], int(d["Hours"]))
            self.db.update_subject(self.selected_code, obj)

        self.view()

    # ================= SWITCH =================

    def switch(self, mode):
        if mode == "student":
            self.build_student()
        elif mode == "doctor":
            self.build_doctor()
        else:
            self.build_subject()

    # ================= TRASH =================

    def open_trash(self):
        win = tk.Toplevel(self.root)
        win.title("Trash")
        win.geometry("600x400")

        tree = ttk.Treeview(win)
        tree.pack(fill="both", expand=True)

        tree["columns"] = ("Code","Name","Type")
        tree["show"] = "headings"

        for c in ("Code","Name","Type"):
            tree.heading(c, text=c)
            tree.column(c, width=180)

        def load():
            tree.delete(*tree.get_children())
            for i in self.db.trash:
                name = getattr(i, "name", "")
                tree.insert("", "end",
                            values=(i.code, name, type(i).__name__))

        def restore():
            sel = tree.focus()
            val = tree.item(sel, "values")
            if val:
                self.db.restore(val[0])
                load()
                self.view()

        def delete_forever():
            sel = tree.focus()
            val = tree.item(sel, "values")
            if val:
                self.db.trash = [x for x in self.db.trash if x.code != val[0]]
                load()

        tk.Button(win, text="Restore", bg="green", fg="white",
                  command=restore).pack()

        tk.Button(win, text="Delete Forever", bg="red", fg="white",
                  command=delete_forever).pack()

        load()


# ================= RUN =================

root = tk.Tk()
AppGUI(root)
root.mainloop()
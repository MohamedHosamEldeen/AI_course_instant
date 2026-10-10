import tkinter as tk
from tkinter import messagebox
from tkinter import ttk

# ================= OOP Classes =================

class Person:
    def __init__(self, name, age, code):
        self.name = name
        self.age = age
        self.code = code


class Student(Person):
    def __init__(self, name, age, code, gpa, hours, subjects, department):
        super().__init__(name, age, code)
        self.__gpa = gpa
        self.hours = hours
        self.subjects = subjects
        self.department = department

    def display(self):
        return (self.code, self.name, f"GPA:{self.__gpa}", self.department)


class Doctor(Person):
    def __init__(self, name, age, code, subject, department, salary):
        super().__init__(name, age, code)
        self.subject = subject
        self.department = department
        self.salary = salary

    def display(self):
        return (self.code, self.name, self.subject, self.department, str(self.salary))


class Subject:
    def __init__(self, name, code, hours):
        self.name = name
        self.code = code
        self.hours = hours

    def display(self):
        return (self.code, self.name, str(self.hours))


class Database:
    def __init__(self):
        self.people = []
        self.subjects = []

    def add_person(self, person):
        for p in self.people:
            if p.code == person.code:
                return False
        self.people.append(person)
        return True

    def add_subject(self, subject):
        for s in self.subjects:
            if s.code == subject.code:
                return False
        self.subjects.append(subject)
        return True


class SystemManager:
    def __init__(self):
        self.db = Database()

    def add_student(self, *args):
        return self.db.add_person(Student(*args))

    def add_doctor(self, *args):
        return self.db.add_person(Doctor(*args))

    def add_subject(self, *args):
        return self.db.add_subject(Subject(*args))

    def get_people(self):
        return self.db.people

    def get_subjects(self):
        return self.db.subjects


# ================= GUI =================

class AppGUI:
    def __init__(self, root):
        self.manager = SystemManager()
        self.root = root
        self.root.title("University System Pro")
        self.root.geometry("980x600")

        # ===== Style =====
        style = ttk.Style()
        style.theme_use("clam")

        style.configure("Treeview",
                        background="#ecf0f1",
                        fieldbackground="#ecf0f1",
                        rowheight=28)

        style.configure("Treeview.Heading",
                        font=("Arial", 11, "bold"),
                        background="#2f3640",
                        foreground="white")

        # ===== Layout =====
        self.container = tk.Frame(root, bg="#f5f6fa")
        self.container.pack(fill="both", expand=True)

        self.menu = tk.Frame(self.container, bg="#2f3640", width=200)
        self.menu.pack(side="left", fill="y")

        self.main = tk.Frame(self.container, bg="#f5f6fa")
        self.main.pack(side="right", expand=True, fill="both")

        tk.Label(self.menu, text="MENU", bg="#2f3640", fg="white",
                 font=("Arial", 16, "bold")).pack(pady=20)

        tk.Button(self.menu, text="Students", command=lambda: self.switch("student"), bg="#353b48", fg="white").pack(pady=8)
        tk.Button(self.menu, text="Doctors", command=lambda: self.switch("doctor"), bg="#353b48", fg="white").pack(pady=8)
        tk.Button(self.menu, text="Subjects", command=lambda: self.switch("subject"), bg="#353b48", fg="white").pack(pady=8)

        # ===== Title =====
        self.title = tk.Label(self.main, text="", font=("Arial", 20, "bold"), bg="#f5f6fa")
        self.title.pack(pady=10)

        # ===== Form =====
        self.form = tk.Frame(self.main, bg="#f5f6fa")
        self.form.pack(pady=10)

        self.btn_frame = tk.Frame(self.main, bg="#f5f6fa")
        self.btn_frame.pack(pady=10)

        # ===== Table (Interactive) =====
        self.tree = ttk.Treeview(self.main)
        self.tree.pack(pady=10, fill="both", expand=True)
        self.tree.bind("<<TreeviewSelect>>", self.on_select)

        self.entries = {}
        self.current_mode = "student"

        self.build_student()

    # ===== Form =====

    def clear_form(self):
        for w in self.form.winfo_children():
            w.destroy()
        for w in self.btn_frame.winfo_children():
            w.destroy()
        self.entries.clear()

    def create_field(self, name, row):
        tk.Label(self.form, text=name, bg="#f5f6fa").grid(row=row, column=0, padx=5, pady=5)
        e = tk.Entry(self.form)
        e.grid(row=row, column=1, padx=5, pady=5)
        self.entries[name] = e

    # ===== Build Modes =====

    def build_student(self):
        self.clear_form()
        self.title.config(text="Students")
        fields = ["Name","Age","Code","GPA","Hours","Subjects","Department"]
        for i,f in enumerate(fields):
            self.create_field(f,i)
        self.create_buttons()
        self.setup_table(["Code","Name","GPA","Department"])

    def build_doctor(self):
        self.clear_form()
        self.title.config(text="Doctors")
        fields = ["Name","Age","Code","Subject","Department","Salary"]
        for i,f in enumerate(fields):
            self.create_field(f,i)
        self.create_buttons()
        self.setup_table(["Code","Name","Subject","Department","Salary"])

    def build_subject(self):
        self.clear_form()
        self.title.config(text="Subjects")
        fields = ["Name","Code","Hours"]
        for i,f in enumerate(fields):
            self.create_field(f,i)
        self.create_buttons()
        self.setup_table(["Code","Name","Hours"])

    # ===== Buttons =====

    def create_buttons(self):
        tk.Button(self.btn_frame, text="Add", bg="#44bd32", fg="white",
                  command=self.add).grid(row=0, column=0, padx=10)
        tk.Button(self.btn_frame, text="View", bg="#0097e6", fg="white",
                  command=self.view).grid(row=0, column=1, padx=10)

    # ===== Table =====

    def setup_table(self, cols):
        self.tree.delete(*self.tree.get_children())
        self.tree["columns"] = cols
        self.tree["show"] = "headings"

        for c in cols:
            self.tree.heading(c, text=c)
            self.tree.column(c, width=120)

    # ===== Add =====

    def add(self):
        data = {k:v.get() for k,v in self.entries.items()}

        if "" in data.values():
            messagebox.showerror("Error","Fill all fields")
            return

        if self.current_mode == "student":
            ok = self.manager.add_student(
                data["Name"], int(data["Age"]), data["Code"], float(data["GPA"]),
                int(data["Hours"]), data["Subjects"], data["Department"])

        elif self.current_mode == "doctor":
            ok = self.manager.add_doctor(
                data["Name"], int(data["Age"]), data["Code"],
                data["Subject"], data["Department"], float(data["Salary"]))

        else:
            ok = self.manager.add_subject(
                data["Name"], data["Code"], int(data["Hours"]))

        if not ok:
            messagebox.showerror("Error","Code already exists!")
        else:
            self.view()

    # ===== View =====

    def view(self):
        self.tree.delete(*self.tree.get_children())

        if self.current_mode == "student":
            for p in self.manager.get_people():
                if isinstance(p, Student):
                    self.tree.insert("", "end", values=p.display())

        elif self.current_mode == "doctor":
            for p in self.manager.get_people():
                if isinstance(p, Doctor):
                    self.tree.insert("", "end", values=p.display())

        else:
            for s in self.manager.get_subjects():
                self.tree.insert("", "end", values=s.display())

    # ===== Interactive Select =====

    def on_select(self, event):
        selected = self.tree.focus()
        values = self.tree.item(selected, "values")

        if not values:
            return

        # Auto fill Code only for quick interaction
        if "Code" in self.entries:
            self.entries["Code"].delete(0, tk.END)
            self.entries["Code"].insert(0, values[0])

    # ===== Switch =====

    def switch(self, mode):
        self.current_mode = mode
        if mode == "student":
            self.build_student()
        elif mode == "doctor":
            self.build_doctor()
        else:
            self.build_subject()


# ================= Run =================

if __name__ == "__main__":
    root = tk.Tk()
    app = AppGUI(root)
    root.mainloop()
"use client"

import { motion, useScroll, useTransform } from "framer-motion"
import { useRef, useState } from "react"
import {
  CheckCircle2,
  Circle,
  Cloud,
  Plus,
  X,
  Play,
  SkipForward,
  RotateCcw,
  Mic,
  Calendar,
} from "lucide-react"

interface Task {
  id: string
  text: string
  completed: boolean
  category?: string
}

interface Note {
  id: string
  text: string
}

interface Project {
  id: string
  name: string
  tasks: { id: string; text: string }[]
}

export function ProductDemoSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end end"],
  })

  // Projector effect - starts hidden above and slides down
  const projectorY = useTransform(scrollYProgress, [0, 0.3, 0.6], ["-100%", "-100%", "0%"])
  const projectorOpacity = useTransform(scrollYProgress, [0.3, 0.5], [0, 1])
  const projectorScale = useTransform(scrollYProgress, [0.3, 0.6], [0.95, 1])

  // Interactive state
  const [tasks, setTasks] = useState<Task[]>([
    { id: "1", text: "Review weekly priorities", completed: false, category: "Personal" },
    { id: "2", text: "Book dentist appointment", completed: false, category: "Personal" },
    { id: "3", text: "Send invoice reminder", completed: false, category: "Work" },
    { id: "4", text: "Pick up groceries", completed: false },
    { id: "5", text: "Plan weekend hike", completed: false },
    { id: "6", text: "Organize tax documents", completed: false, category: "Personal" },
  ])

  const [notes, setNotes] = useState<Note[]>([
    { id: "1", text: "Ideas for Friday demo" },
    { id: "2", text: "Questions for team sync" },
  ])

  const [projects, setProjects] = useState<Project[]>([
    {
      id: "1",
      name: "Website Launch",
      tasks: [
        { id: "1", text: "Finalize homepage copy" },
        { id: "2", text: "Check mobile layout" },
        { id: "3", text: "Connect payment button" },
      ],
    },
  ])

  const [brainDumps, setBrainDumps] = useState<string[]>([])
  const [newTaskText, setNewTaskText] = useState("")
  const [newNoteText, setNewNoteText] = useState("")
  const [newBrainDump, setNewBrainDump] = useState("")
  const [timerMinutes] = useState(24)
  const [timerSeconds] = useState(58)
  const [isTimerRunning, setIsTimerRunning] = useState(false)
  const [editingTaskId, setEditingTaskId] = useState<string | null>(null)
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null)
  const [editingProjectTaskId, setEditingProjectTaskId] = useState<string | null>(null)
  const [newProjectTaskText, setNewProjectTaskText] = useState("")

  const addTask = () => {
    if (newTaskText.trim()) {
      setTasks([
        ...tasks,
        { id: Date.now().toString(), text: newTaskText, completed: false },
      ])
      setNewTaskText("")
    }
  }

  const toggleTask = (id: string) => {
    setTasks(
      tasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      )
    )
  }

  const deleteTask = (id: string) => {
    setTasks(tasks.filter((task) => task.id !== id))
  }

  const addNote = () => {
    if (newNoteText.trim()) {
      setNotes([...notes, { id: Date.now().toString(), text: newNoteText }])
      setNewNoteText("")
    }
  }

  const deleteNote = (id: string) => {
    setNotes(notes.filter((note) => note.id !== id))
  }

  const addBrainDump = () => {
    if (newBrainDump.trim()) {
      setBrainDumps([...brainDumps, newBrainDump])
      setNewBrainDump("")
    }
  }

  const updateTaskText = (id: string, newText: string) => {
    setTasks(tasks.map((task) => (task.id === id ? { ...task, text: newText } : task)))
  }

  const updateNoteText = (id: string, newText: string) => {
    setNotes(notes.map((note) => (note.id === id ? { ...note, text: newText } : note)))
  }

  const updateProjectTaskText = (taskId: string, newText: string) => {
    setProjects(
      projects.map((project) => ({
        ...project,
        tasks: project.tasks.map((task) =>
          task.id === taskId ? { ...task, text: newText } : task
        ),
      }))
    )
  }

  const deleteProjectTask = (taskId: string) => {
    setProjects(
      projects.map((project) => ({
        ...project,
        tasks: project.tasks.filter((task) => task.id !== taskId),
      }))
    )
  }

  const addProjectTask = () => {
    if (newProjectTaskText.trim()) {
      setProjects(
        projects.map((project) => ({
          ...project,
          tasks: [
            ...project.tasks,
            { id: Date.now().toString(), text: newProjectTaskText },
          ],
        }))
      )
      setNewProjectTaskText("")
    }
  }

  return (
    <section
      ref={containerRef}
      className="relative min-h-[150vh] bg-gradient-to-b from-[#a8d4ef] to-background overflow-hidden"
    >
      {/* Cloud Widget at the very top */}
      <div className="sticky top-0 z-20 flex justify-center pt-0">
        <motion.div
          initial={{ y: -20, opacity: 0 }}
          whileInView={{ y: 0, opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="flex h-[70px] w-[240px] justify-center"
        >
          <div
            className="flex h-11 items-center gap-2 rounded-b-[22px] bg-primary px-8 text-sm font-semibold text-primary-foreground shadow-lg shadow-primary/20"
            aria-label="Cloud notch"
          >
            <Cloud className="h-4 w-4 fill-primary-foreground/25" aria-hidden="true" />
            <span>Cloud</span>
          </div>
        </motion.div>
      </div>

      {/* Product Demo Container - Slides down like a projector */}
      <motion.div
        style={{ 
          y: projectorY, 
          opacity: projectorOpacity, 
          scale: projectorScale,
        }}
        className="sticky top-16 mx-auto max-w-6xl px-4 z-10 pt-8"
      >
        <motion.h2
          initial={{ y: 20, opacity: 0 }}
          whileInView={{ y: 0, opacity: 1 }}
          viewport={{ once: true }}
          className="mb-4 text-center text-3xl font-bold text-foreground md:text-4xl"
        >
          Everything you need, one click away
        </motion.h2>
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          whileInView={{ y: 0, opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.1 }}
          className="mb-12 text-center text-muted-foreground"
        >
          Try it yourself - click, add tasks, and see how it works
        </motion.p>

        {/* Interactive Product Demo */}
        <div
          className="relative mx-auto overflow-hidden rounded-2xl bg-[#d0e5f5] p-4 shadow-2xl"
        >
          {/* Header */}
          <div className="flex items-center justify-between mb-4 bg-[#d0e5f5] rounded-t-xl px-2">
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1 bg-primary text-primary-foreground px-3 py-1.5 rounded-full text-sm font-medium">
                <span className="text-primary-foreground">☁️</span> Cloud
              </div>
              <button className="flex items-center gap-1 bg-primary text-primary-foreground px-3 py-1.5 rounded-full text-sm font-medium">
                🏠 Home
              </button>
              <button className="flex items-center gap-1 text-primary px-3 py-1.5 rounded-full text-sm font-medium hover:bg-primary/10 transition-colors">
                📊 Stats
              </button>
            </div>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <span>{tasks.length + projects[0].tasks.length} tasks</span>
              <button className="flex items-center gap-1 border border-primary/30 text-primary px-3 py-1.5 rounded-full text-sm font-medium hover:bg-primary/10 transition-colors">
                ⬚ Widgets
              </button>
              <button className="w-6 h-6 rounded-full bg-primary/20 text-primary flex items-center justify-center">
                ✕
              </button>
            </div>
          </div>

          {/* Main Content Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Tasks Section */}
            <div className="bg-card rounded-xl p-4 shadow-sm">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-primary" />
                  <span className="font-semibold text-card-foreground">Tasks</span>
                  <span className="bg-primary/20 text-primary text-xs px-1.5 py-0.5 rounded-full">
                    {tasks.filter((t) => !t.completed).length}
                  </span>
                </div>
              </div>

              {/* Add Task Input */}
              <div className="flex gap-2 mb-3">
                <div className="flex-1 flex items-center gap-2 border border-border rounded-full px-3 py-1.5">
                  <Plus className="w-4 h-4 text-primary" />
                  <input
                    type="text"
                    value={newTaskText}
                    onChange={(e) => setNewTaskText(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && addTask()}
                    placeholder="Add a task..."
                    className="flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground"
                  />
                </div>
                <button className="bg-primary/20 text-primary text-xs px-3 py-1.5 rounded-full font-medium">
                  ● Personal
                </button>
              </div>

              {/* Task List */}
              <div className="space-y-2 max-h-64 overflow-y-auto">
                {tasks.map((task) => (
                  <motion.div
                    key={task.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: 20 }}
                    className="flex items-center gap-2 group"
                  >
                    <button
                      onClick={() => toggleTask(task.id)}
                      className="flex-shrink-0"
                    >
                      {task.completed ? (
                        <CheckCircle2 className="w-5 h-5 text-primary" />
                      ) : (
                        <Circle className="w-5 h-5 text-muted-foreground" />
                      )}
                    </button>
                    {editingTaskId === task.id ? (
                      <input
                        type="text"
                        value={task.text}
                        onChange={(e) => updateTaskText(task.id, e.target.value)}
                        onBlur={() => setEditingTaskId(null)}
                        onKeyDown={(e) => e.key === "Enter" && setEditingTaskId(null)}
                        autoFocus
                        className="flex-1 text-sm bg-secondary/50 px-2 py-0.5 rounded outline-none focus:ring-2 focus:ring-primary/50"
                      />
                    ) : (
                      <span
                        onClick={() => setEditingTaskId(task.id)}
                        className={`flex-1 text-sm cursor-text hover:bg-secondary/30 px-1 rounded ${
                          task.completed
                            ? "line-through text-muted-foreground"
                            : "text-card-foreground"
                        }`}
                      >
                        {task.text}
                      </span>
                    )}
                    {task.category && (
                      <span className="text-xs text-primary">{task.category}</span>
                    )}
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <span className="w-2 h-2 rounded-full bg-primary" />
                      <button
                        onClick={() => deleteTask(task.id)}
                        className="text-muted-foreground hover:text-destructive"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  </motion.div>
                ))}
              </div>
              <p className="text-xs text-muted-foreground mt-2">
                {tasks.filter((t) => !t.completed).length} remaining
              </p>
            </div>

            {/* Projects Section */}
            <div className="space-y-4">
              <div className="bg-card rounded-xl p-4 shadow-sm">
                <div className="flex items-center gap-2 mb-3 text-sm text-primary">
                  <span>{"<"}</span>
                  <span className="font-medium">Projects</span>
                  <span>/</span>
                  <span className="font-semibold text-card-foreground">
                    {projects[0].name}
                  </span>
                </div>

                <div className="flex gap-2 mb-3">
                  <div className="flex-1 flex items-center gap-2 border border-border rounded-full px-3 py-1.5">
                    <Plus className="w-4 h-4 text-primary" />
                    <input
                      type="text"
                      value={newProjectTaskText}
                      onChange={(e) => setNewProjectTaskText(e.target.value)}
                      onKeyDown={(e) => e.key === "Enter" && addProjectTask()}
                      placeholder="Add project task..."
                      className="flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  {projects[0].tasks.map((task) => (
                    <div key={task.id} className="flex items-center gap-2 group">
                      <Circle className="w-5 h-5 text-muted-foreground flex-shrink-0" />
                      {editingProjectTaskId === task.id ? (
                        <input
                          type="text"
                          value={task.text}
                          onChange={(e) => updateProjectTaskText(task.id, e.target.value)}
                          onBlur={() => setEditingProjectTaskId(null)}
                          onKeyDown={(e) => e.key === "Enter" && setEditingProjectTaskId(null)}
                          autoFocus
                          className="flex-1 text-sm bg-secondary/50 px-2 py-0.5 rounded outline-none focus:ring-2 focus:ring-primary/50"
                        />
                      ) : (
                        <span
                          onClick={() => setEditingProjectTaskId(task.id)}
                          className="flex-1 text-sm text-card-foreground cursor-text hover:bg-secondary/30 px-1 rounded"
                        >
                          {task.text}
                        </span>
                      )}
                      <button
                        onClick={() => deleteProjectTask(task.id)}
                        className="text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity hover:text-destructive"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  {projects[0].tasks.length} remaining
                </p>
              </div>

              {/* Notes Section */}
              <div className="bg-card rounded-xl p-4 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span>📝</span>
                    <span className="font-semibold text-primary">Notes</span>
                  </div>
                  <button
                    onClick={addNote}
                    className="w-5 h-5 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xs"
                  >
                    +
                  </button>
                </div>
                <div className="space-y-2">
                  {notes.map((note) => (
                    <div
                      key={note.id}
                      className="flex items-center justify-between bg-secondary/50 rounded-lg px-3 py-2 group"
                    >
                      {editingNoteId === note.id ? (
                        <input
                          type="text"
                          value={note.text}
                          onChange={(e) => updateNoteText(note.id, e.target.value)}
                          onBlur={() => setEditingNoteId(null)}
                          onKeyDown={(e) => e.key === "Enter" && setEditingNoteId(null)}
                          autoFocus
                          className="flex-1 text-sm bg-card px-2 py-0.5 rounded outline-none focus:ring-2 focus:ring-primary/50"
                        />
                      ) : (
                        <span
                          onClick={() => setEditingNoteId(note.id)}
                          className="flex-1 text-sm text-card-foreground cursor-text hover:bg-secondary/70 px-1 rounded"
                        >
                          {note.text}
                        </span>
                      )}
                      <button
                        onClick={() => deleteNote(note.id)}
                        className="text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity hover:text-destructive ml-2"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Up Next Section */}
              <div className="bg-card rounded-xl p-4 shadow-sm">
                <div className="flex items-center gap-2 mb-2">
                  <Calendar className="w-4 h-4 text-primary" />
                  <span className="font-semibold text-primary">Up Next</span>
                </div>
                <p className="text-sm text-muted-foreground">No upcoming events</p>
              </div>
            </div>

            {/* Right Column - Timer & Brain Dump */}
            <div className="space-y-4">
              {/* Focus Timer */}
              <div className="bg-card rounded-xl p-4 shadow-sm">
                <div className="flex items-center justify-between">
                  <div className="relative w-16 h-16">
                    <svg className="w-16 h-16 -rotate-90">
                      <circle
                        cx="32"
                        cy="32"
                        r="28"
                        stroke="currentColor"
                        strokeWidth="4"
                        fill="none"
                        className="text-secondary"
                      />
                      <circle
                        cx="32"
                        cy="32"
                        r="28"
                        stroke="currentColor"
                        strokeWidth="4"
                        fill="none"
                        strokeDasharray={175.93}
                        strokeDashoffset={175.93 * 0.17}
                        className="text-primary"
                      />
                    </svg>
                  </div>
                  <div className="flex flex-col items-center">
                    <span className="text-3xl font-bold text-card-foreground">
                      {timerMinutes}:{timerSeconds.toString().padStart(2, "0")}
                    </span>
                    <span className="text-sm text-primary">Focus</span>
                  </div>
                  <div className="flex gap-2">
                    <button className="w-8 h-8 rounded-full bg-secondary flex items-center justify-center text-muted-foreground hover:text-card-foreground transition-colors">
                      <RotateCcw className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => setIsTimerRunning(!isTimerRunning)}
                      className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-primary-foreground"
                    >
                      <Play className="w-4 h-4" />
                    </button>
                    <button className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-primary-foreground">
                      <SkipForward className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>

              {/* Brain Dump */}
              <div className="bg-card rounded-xl p-4 shadow-sm">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span>🧠</span>
                    <span className="font-semibold text-primary">Brain Dump</span>
                  </div>
                  <button className="w-6 h-6 rounded-full bg-primary/20 text-primary flex items-center justify-center">
                    ✕
                  </button>
                </div>

                <div className="flex items-center gap-2 mb-4 bg-secondary/50 rounded-lg px-3 py-2">
                  <Mic className="w-4 h-4 text-primary" />
                  <span className="text-sm text-muted-foreground">
                    Tap mic to enable voice
                  </span>
                </div>

                <input
                  type="text"
                  value={newBrainDump}
                  onChange={(e) => setNewBrainDump(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && addBrainDump()}
                  placeholder="Type your thoughts..."
                  className="w-full border border-border rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-primary/50 mb-3"
                />

                {brainDumps.length === 0 ? (
                  <div className="text-center py-6">
                    <span className="text-4xl">🧠</span>
                    <p className="text-sm text-muted-foreground mt-2">
                      No brain dumps yet
                    </p>
                  </div>
                ) : (
                  <div className="space-y-2 max-h-32 overflow-y-auto">
                    {brainDumps.map((dump, i) => (
                      <div
                        key={i}
                        className="bg-secondary/50 rounded-lg px-3 py-2 text-sm text-card-foreground"
                      >
                        {dump}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </motion.div>
    </section>
  )
}

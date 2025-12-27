const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Supabase Client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

let supabase = null;
let mockTasks = [];
let mockIdCounter = 1;
const isMockMode = !supabaseUrl || !supabaseKey || supabaseUrl.includes('YOUR_SUPABASE_URL');

if (!isMockMode) {
    supabase = createClient(supabaseUrl, supabaseKey);
    console.log("Connected to Supabase.");
} else {
    console.log("Supabase keys missing or invalid. Running in MOCK MODE (In-Memory).");
}

// --- AUTO-CLASSIFICATION LOGIC ---

const classifyTask = (title, description) => {
    const text = (title + " " + (description || "")).toLowerCase();

    // 1. Category Detection
    let category = 'general';
    // Safety First! (Prioritize safety keywords over others like 'fix' which might be technical but if it's a hazard, it's safety)
    if (/(safety|hazard|inspection|compliance|ppe|helmet|danger|gas|leak)/.test(text)) category = 'safety';
    else if (/(meeting|schedule|call|appointment|deadline|calendar)/.test(text)) category = 'scheduling';
    else if (/(payment|invoice|bill|budget|cost|expense|price)/.test(text)) category = 'finance';
    else if (/(bug|fix|error|install|repair|maintain|broken)/.test(text)) category = 'technical';

    // 2. Priority Detection
    let priority = 'low';
    if (/(urgent|asap|immediately|today|critical|emergency)/.test(text)) priority = 'high';
    else if (/(soon|this week|important|needed)/.test(text)) priority = 'medium';

    // 3. Entity Extraction
    const extracted_entities = {
        dates: [],
        locations: []
    };

    // Simple date extraction (YYYY-MM-DD or keywords)
    const dateMatches = text.match(/\b\d{4}-\d{2}-\d{2}\b|\b(today|tomorrow)\b/g);
    if (dateMatches) extracted_entities.dates = dateMatches;

    // 4. Suggested Actions
    let suggested_actions = [];
    switch (category) {
        case 'scheduling': suggested_actions = ["Block calendar", "Send invite", "Set reminder"]; break;
        case 'finance': suggested_actions = ["Check budget", "Get approval", "Process payment"]; break;
        case 'technical': suggested_actions = ["Diagnose issue", "Assign technician", "Order parts"]; break;
        case 'safety': suggested_actions = ["Conduct inspection", "File incident report", "Stop work"]; break;
    }

    return { category, priority, extracted_entities, suggested_actions };
};

// --- ENDPOINTS ---

// GET /api/tasks
app.get('/api/tasks', async (req, res) => {
    if (isMockMode) {
        const { status, category, priority } = req.query;
        let filtered = [...mockTasks];
        if (status) filtered = filtered.filter(t => t.status === status);
        if (category) filtered = filtered.filter(t => t.category === category);
        if (priority) filtered = filtered.filter(t => t.priority === priority);
        // Sort by created_at desc (mock IDs are creating order)
        filtered.sort((a, b) => b.id_num - a.id_num);
        return res.json(filtered);
    }

    const { status, category, priority } = req.query;
    let query = supabase.from('tasks').select('*').order('created_at', { ascending: false });

    if (status) query = query.eq('status', status);
    if (category) query = query.eq('category', category);
    if (priority) query = query.eq('priority', priority);

    const { data, error } = await query;
    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
});

// POST /api/tasks
app.post('/api/tasks', async (req, res) => {
    const { title, description, assigned_to, due_date } = req.body;
    if (!title) return res.status(400).json({ error: "Title is required" });

    // Auto-Classify
    const classification = classifyTask(title, description);

    const newTask = {
        title,
        description,
        assigned_to,
        due_date,
        status: 'pending',
        ...classification
    };

    if (isMockMode) {
        const mockTask = {
            id: `mock-${mockIdCounter++}`,
            id_num: mockIdCounter, // for sorting
            ...newTask,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        };
        mockTasks.push(mockTask);
        return res.status(201).json(mockTask);
    }

    const { data, error } = await supabase.from('tasks').insert([newTask]).select();
    if (error) return res.status(500).json({ error: error.message });

    // Log History
    if (data && data.length > 0) {
        await supabase.from('task_history').insert([{
            task_id: data[0].id,
            action: 'created',
            new_value: data[0]
        }]);
    }

    res.status(201).json(data[0]);
});

// GET /api/tasks/:id
app.get('/api/tasks/:id', async (req, res) => {
    const { id } = req.params;

    if (isMockMode) {
        const task = mockTasks.find(t => t.id === id);
        if (!task) return res.status(404).json({ error: "Task not found" });
        return res.json(task);
    }

    const { data, error } = await supabase.from('tasks').select('*').eq('id', id).single();
    if (error) return res.status(error.code === 'PGRST116' ? 404 : 500).json({ error: error.message });
    res.json(data);
});

// PATCH /api/tasks/:id
app.patch('/api/tasks/:id', async (req, res) => {
    const { id } = req.params;
    const updates = req.body;

    if (isMockMode) {
        const index = mockTasks.findIndex(t => t.id === id);
        if (index === -1) return res.status(404).json({ error: "Task not found" });

        mockTasks[index] = { ...mockTasks[index], ...updates, updated_at: new Date().toISOString() };
        return res.json(mockTasks[index]);
    }

    // Get old val for history
    const { data: oldTask } = await supabase.from('tasks').select('*').eq('id', id).single();
    if (!oldTask) return res.status(404).json({ error: "Task not found" });

    const { data, error } = await supabase.from('tasks').update(updates).eq('id', id).select();
    if (error) return res.status(500).json({ error: error.message });

    // Log History
    await supabase.from('task_history').insert([{
        task_id: id,
        action: 'updated',
        old_value: oldTask,
        new_value: data[0]
    }]);

    res.json(data[0]);
});

// DELETE /api/tasks/:id
app.delete('/api/tasks/:id', async (req, res) => {
    const { id } = req.params;

    if (isMockMode) {
        const index = mockTasks.findIndex(t => t.id === id);
        if (index === -1) return res.status(404).json({ error: "Task not found" });
        mockTasks.splice(index, 1);
        return res.status(204).send();
    }

    const { error } = await supabase.from('tasks').delete().eq('id', id);
    if (error) return res.status(500).json({ error: error.message });
    res.status(204).send();
});

app.listen(port, () => {
    console.log(`Smart Site Task Manager API running on port ${port}`);
});

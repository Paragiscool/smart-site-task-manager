// const fetch = require('node-fetch'); // Removed to avoid missing dependency


// Polyfill fetch if node version < 18 (unlikely but safe)
// Actually in recent node, fetch is global. If not, this might fail, but let's try standard fetch first.

async function testBackend() {
    console.log("TEST: Verifying Backend Auto-Classification Logic...");
    console.log("----------------------------------------------------");

    const payload = {
        title: "Fix gas leak in the basement ASAP",
        description: "Smell is very strong, need inspection."
    };

    try {
        const response = await fetch('http://localhost:3000/api/tasks', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            throw new Error(`HTTP Error: ${response.status}`);
        }

        const data = await response.json();

        console.log("Sent Task:", payload);
        console.log("Received Response:", data);
        console.log("----------------------------------------------------");

        // Assertions
        const categoryMatch = data.category === 'safety';
        const priorityMatch = data.priority === 'high';

        if (categoryMatch && priorityMatch) {
            console.log("✅ SUCCESS CRITERIA MET");
            console.log("   Category: 'safety' (Correct)");
            console.log("   Priority: 'high' (Correct)");
        } else {
            console.error("❌ FAILED");
            console.error(`   Expected: Category=safety, Priority=high`);
            console.error(`   Actual:   Category=${data.category}, Priority=${data.priority}`);
        }

    } catch (e) {
        console.error("Error connecting to backend:", e.message);
        console.log("Is the server running on port 3000?");
    }
}

testBackend();

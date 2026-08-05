// Eman Life & Home Management App — Complete Core JavaScript Logic
const STORAGE_KEY = 'eman_app_full_data_v3';

// ============================================================
// 🔑 SHARED AI KEY — مفتاح الذكاء الاصطناعي للتطبيق
// App owner: paste your FREE Gemini API key here once.
// Get a free key at: https://aistudio.google.com/app/apikey
// Free tier: 1,500 requests/day — enough for personal use.
// ============================================================
const SHARED_APP_KEY = ''; // ← ضعي مفتاح Gemini هنا (يبدأ بـ AIzaSy...)

// HTML sanitizer – prevents XSS when injecting user data into innerHTML
function sanitize(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// Default initial state
let appData = {
    settings: {
        geminiApiKey: '', // Set your Gemini API key in Settings (gear icon)
        wifeName: 'إيمان'
    },
    goalsCascade: [
        { id: 1, title: 'ختم القرآن الكريم وتدبر معانيه', level: 'سنة', targetDate: '2026-12-31', progress: 50, details: 'قراءة جزء يومياً مفسر' },
        { id: 2, title: 'الحفاظ على روتين الرياضة والصحة', level: 'شهر', targetDate: '2026-08-31', progress: 75, details: '4 حصص تمارين مقاومة شهرياً' }
    ],
    weeklyIndependentTasks: {
        currentWeek: [
            { id: 1, title: 'تنظيم وترتيب خزانة الملابس الرئيسية', day: 'الأحد', done: false },
            { id: 2, title: 'شراء المقاضي والمؤونة الطازجة للأسبوع', day: 'الثلاثاء', done: true },
            { id: 3, title: 'جلسة عناية بالشعر والوجه', day: 'الخميس', done: false }
        ],
        archives: []
    },
    categorizedTasks: [
        { id: 1, title: 'مراجعة واجبات الأطفال المدرسية', category: 'أطفال', reminderTime: '17:00', done: false },
        { id: 2, title: 'قراءة سورة الكهف والورد الأسبوعي', category: 'شخصي', reminderTime: '10:00', done: true },
        { id: 3, title: 'تنظيف وتعقيم الأجهزة الكهربائية بالمطبخ', category: 'بيت', reminderTime: '11:00', done: false }
    ],
    workouts: [
        { id: 1, muscleName: 'عضلات الظهر والكتف الخلفي', day: 'الأحد', technique: 'سحب بار علوي (4x12) + دنابل كتف (3x10)', sets: 4, reps: 12, photo: '' },
        { id: 2, muscleName: 'تمارين الجزء السفلي والأرجل', day: 'الثلاثاء', technique: 'سكوات (3x15) + طعن متناول (3x12)', sets: 3, reps: 15, photo: '' }
    ],
    journalEntries: [
        { id: 1, title: 'يوم حافل بالهدوء والإنجاز', type: 'نص', content: 'الحمد لله أتممت وردي اليومي واستمتعت بوقي مع الأسرة.', date: '2026-07-26', audioUrl: '' }
    ],
    booksAndQuran: {
        quranPage: 142,
        books: [
            { id: 1, title: 'كتاب لأنك الله', author: 'علي بن جابر الفيفي', totalPages: 192, currentPage: 120, rating: 5 }
        ]
    },
    generalNotes: [
        { id: 1, title: 'أفكار لتجديد الصالة', text: 'إضافة إضاءة دافئة ونباتات طبيعية على الأرفف', category: 'ديكور', date: '2026-07-25' }
    ],
    recipes: [
        { id: 1, title: 'كبسة دجاج بالشعلان', mealTime: 'غداء', ingredients: 'دجاج، أرز بسمتي، بهارات كبسة، بصل، طماطم، مكسرات', weights: '500g دجاج | 2 كوب أرز', photo: '' },
        { id: 2, title: 'شوفان بالفواكه والعسل', mealTime: 'إفطار', ingredients: 'شوفان، حليب، موز، عسل، بذور الشيا', weights: '50g شوفان | 200ml حليب', photo: '' }
    ],
    pantryItems: [
        { id: 1, name: 'زيت زيتون بكر ممتاز', category: 'زيوت', quantity: '2 لتر', bought: false },
        { id: 2, name: 'مكسرات مشكلة (جوز ولوز)', category: 'مكسرات', quantity: '500 جرام', bought: true },
        { id: 3, name: 'أسطوانة غاز احتياطية', category: 'منزل', quantity: '1', bought: false }
    ],
    laundrySchedule: [
        { id: 1, day: 'الأحد', time: '10:00 صباحاً', colorType: 'الملابس البيضاء', fabricType: 'قطنيات', method: 'غسيل دافئ (40°C) + مطهر ملابس' },
        { id: 2, day: 'الثلاثاء', time: '04:00 مساءً', colorType: 'الملابس الملونة', fabricType: 'ناعم / حرير', method: 'غسيل بارد + شامبو عبايات' }
    ],
    beautyProducts: [
        { id: 1, name: 'سيروم فيتامين سي', type: 'بشرة (صباحاً)', instructions: 'تطبيق 4 قطرات على البشرة بعد الغسول وقبل واقي الشمس' },
        { id: 2, name: 'ماسك السدر وزيت الأرغان', type: 'شعر (أسبوعي)', instructions: 'يوضع على الشعر لمدة 60 دقيقة قبل الاستحمام' }
    ],
    medications: [
        { id: 1, name: 'فيتامين د3 (5000 IU)', time: '09:00 صباحاً', dosage: 'حبة واحدة يومياً', notes: 'مع وجبة الإفطار تحتوي على دهون صحية', taken: true },
        { id: 2, name: 'كولاجين للبشرة والشعر', time: '10:00 مساءً', dosage: 'كيس واحد في كوب ماء', notes: 'قبل النوم', taken: false }
    ],
    finances: {
        salary: 12000,
        items: [
            { id: 1, title: 'فاتورة الكهرباء والماء', category: 'فواتير', amount: 450, dueDate: '28 من الشهر' },
            { id: 2, title: 'مقاضي ومستلزمات الشهر', category: 'تسوق', amount: 2500, dueDate: 'أول الشهر' },
            { id: 3, title: 'ادخار وطوارئ', category: 'ادخار', amount: 2000, dueDate: 'تلقائي' }
        ]
    }
};

// Current active main tab & sub tab state
let currentMainTab = 'tasks';
let currentSubTab = 'cascade';

// MediaRecorder state for Audio Journal
let mediaRecorder = null;
let audioChunks = [];
let isRecording = false;
let currentRecordedAudioUrl = '';

// Load data from LocalStorage – proper deep-merge to avoid losing nested arrays
function loadAppData() {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return; // Use default appData as-is
    try {
        const parsed = JSON.parse(stored);
        if (!parsed || typeof parsed !== 'object') return;

        // Deep-merge settings
        if (parsed.settings && typeof parsed.settings === 'object') {
            appData.settings = { ...appData.settings, ...parsed.settings };
        }
        // NOTE: We no longer inject hardcoded keys. User must set their own key.
        if (!appData.settings.geminiApiKey) appData.settings.geminiApiKey = '';

        // Restore arrays with safe fallbacks
        if (Array.isArray(parsed.goalsCascade))       appData.goalsCascade = parsed.goalsCascade;
        if (Array.isArray(parsed.categorizedTasks))   appData.categorizedTasks = parsed.categorizedTasks;
        if (Array.isArray(parsed.workouts))           appData.workouts = parsed.workouts;
        if (Array.isArray(parsed.journalEntries))     appData.journalEntries = parsed.journalEntries;
        if (Array.isArray(parsed.generalNotes))       appData.generalNotes = parsed.generalNotes;
        if (Array.isArray(parsed.recipes))            appData.recipes = parsed.recipes;
        if (Array.isArray(parsed.pantryItems))        appData.pantryItems = parsed.pantryItems;
        if (Array.isArray(parsed.laundrySchedule))    appData.laundrySchedule = parsed.laundrySchedule;
        if (Array.isArray(parsed.beautyProducts))     appData.beautyProducts = parsed.beautyProducts;
        if (Array.isArray(parsed.medications))        appData.medications = parsed.medications;

        // Deep-merge weeklyIndependentTasks
        if (parsed.weeklyIndependentTasks && typeof parsed.weeklyIndependentTasks === 'object') {
            appData.weeklyIndependentTasks.currentWeek =
                Array.isArray(parsed.weeklyIndependentTasks.currentWeek)
                ? parsed.weeklyIndependentTasks.currentWeek : [];
            appData.weeklyIndependentTasks.archives =
                Array.isArray(parsed.weeklyIndependentTasks.archives)
                ? parsed.weeklyIndependentTasks.archives : [];
        }

        // Deep-merge booksAndQuran (critical: was lost with shallow spread)
        if (parsed.booksAndQuran && typeof parsed.booksAndQuran === 'object') {
            appData.booksAndQuran.quranPage = Number(parsed.booksAndQuran.quranPage) || 1;
            appData.booksAndQuran.books = Array.isArray(parsed.booksAndQuran.books)
                ? parsed.booksAndQuran.books : [];
        }

        // Deep-merge finances
        if (parsed.finances && typeof parsed.finances === 'object') {
            appData.finances.salary = Number(parsed.finances.salary) || 0;
            appData.finances.items = Array.isArray(parsed.finances.items)
                ? parsed.finances.items : [];
        }

    } catch (e) {
        console.error('Error loading stored data – using defaults:', e);
    }
}

// Save data to LocalStorage
function saveAppData() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(appData));
}

// Persistent AI chat history (survives tab switching)
let aiChatHistory = [];

// App Initialization
window.addEventListener('DOMContentLoaded', () => {
    loadAppData();
    switchTab('tasks');

    // Close modal when clicking the dark backdrop
    document.getElementById('global-modal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });

    // Close modal on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });
});

// Switch Main Navigation Tab
function switchTab(tabKey) {
    currentMainTab = tabKey;
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    
    const activeNav = Array.from(document.querySelectorAll('.nav-item')).find(el => el.getAttribute('onclick') && el.getAttribute('onclick').includes(`'${tabKey}'`));
    if (activeNav) activeNav.classList.add('active');

    if (tabKey === 'tasks') currentSubTab = 'cascade';
    else if (tabKey === 'health') currentSubTab = 'workouts';
    else if (tabKey === 'home') currentSubTab = 'recipes';
    else if (tabKey === 'budget') currentSubTab = 'finance';
    else if (tabKey === 'reading') currentSubTab = 'quran';
    else if (tabKey === 'ai') currentSubTab = 'chat';

    renderCurrentView();
}

// Set Sub Tab
function setSubTab(subKey) {
    currentSubTab = subKey;
    renderCurrentView();
}

// Render Active View
function renderCurrentView() {
    const container = document.getElementById('view-container');
    if (!container) return;
    container.innerHTML = '';

    if (currentMainTab === 'tasks') renderTasksView(container);
    else if (currentMainTab === 'health') renderHealthView(container);
    else if (currentMainTab === 'home') renderHomeView(container);
    else if (currentMainTab === 'budget') renderBudgetView(container);
    else if (currentMainTab === 'reading') renderReadingView(container);
    else if (currentMainTab === 'ai') renderAIView(container);
}

// Helper: Empty state HTML
function getEmptyState(message) {
    return `
        <div class="empty-state">
            <i class="fa-solid fa-folder-open"></i>
            <p>${message}</p>
        </div>
    `;
}

/* ==========================================================================
   1. TASKS VIEW (الأهداف الهرمية + الجدول المستقل + المهام المقسمة)
   ========================================================================== */
function renderTasksView(container) {
    let html = `
        <div class="sub-nav">
            <div class="sub-pill ${currentSubTab==='cascade'?'active':''}" onclick="setSubTab('cascade')"><i class="fa-solid fa-sitemap"></i> الأهداف الهرمية (سنة/شهر/أسبوع/يوم)</div>
            <div class="sub-pill ${currentSubTab==='weekly'?'active':''}" onclick="setSubTab('weekly')"><i class="fa-solid fa-calendar-week"></i> الجدول الأسبوعي المستقل والأرشيف</div>
            <div class="sub-pill ${currentSubTab==='categorized'?'active':''}" onclick="setSubTab('categorized')"><i class="fa-solid fa-tags"></i> المهام (شخصية / بيت / أطفال)</div>
        </div>
    `;

    if (currentSubTab === 'cascade') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-bullseye"></i> شجرة الأهداف السنوية والمراحل</div>
                    <button class="btn-primary" onclick="openAddGoalModal()"><i class="fa-solid fa-plus"></i> إضافة هدف جديد</button>
                </div>
                <div class="item-list">
                    ${appData.goalsCascade.length === 0 ? getEmptyState('لا توجد أهداف مضافة بعد. اضغطي على إضافة هدف للبدء!') : ''}
                    ${appData.goalsCascade.map((goal, idx) => `
                        <div class="list-item">
                            <div class="item-content">
                                <div class="item-title">${sanitize(goal.title)} <span class="badge">${sanitize(goal.level)}</span></div>
                                <div class="item-meta">
                                    <span><i class="fa-regular fa-clock"></i> المستهدف: ${sanitize(goal.targetDate || 'غير محدد')}</span>
                                    <span><i class="fa-solid fa-chart-line"></i> الإنجاز: ${goal.progress || 0}%</span>
                                </div>
                                <div class="progress-bar-bg"><div class="progress-bar-fill" style="width: ${Math.min(100, Number(goal.progress || 0))}%"></div></div>
                                ${goal.details ? `<div style="font-size:12px; color:var(--text-sub); margin-top:6px;">${sanitize(goal.details)}</div>` : ''}
                            </div>
                            <div class="item-actions">
                                <button class="icon-btn" onclick="exportToICS(appData.goalsCascade[${idx}].title, 'تذكير بهدف')" title="تصدير للتقويم"><i class="fa-solid fa-calendar-plus"></i></button>
                                <button class="icon-btn" onclick="openEditGoalModal(${idx})" title="تعديل"><i class="fa-solid fa-pen"></i></button>
                                <button class="btn-danger" onclick="deleteGoal(${idx})" title="حذف"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'weekly') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-arrows-rotate"></i> المهام الأسبوعية المستقلة</div>
                    <div style="display:flex; gap:8px;">
                        <button class="btn-secondary" onclick="archiveCurrentWeek()"><i class="fa-solid fa-box-archive"></i> أرشفة وبدء أسبوع جديد</button>
                        <button class="btn-primary" onclick="openAddWeeklyTaskModal()"><i class="fa-solid fa-plus"></i> إضافة مهمة</button>
                    </div>
                </div>
                <div class="item-list">
                    ${appData.weeklyIndependentTasks.currentWeek.length === 0 ? getEmptyState('الجدول الأسبوعي الحالي فارغ.') : ''}
                    ${appData.weeklyIndependentTasks.currentWeek.map((task, idx) => `
                        <div class="list-item ${task.done ? 'completed' : ''}">
                            <div class="custom-check ${task.done ? 'checked' : ''}" onclick="toggleWeeklyTask(${idx})"><i class="fa-solid fa-check"></i></div>
                            <div class="item-content">
                                <div class="item-title">${sanitize(task.title)}</div>
                                <div class="item-meta">اليوم: ${sanitize(task.day || 'الأسبوع')}</div>
                            </div>
                            <div class="item-actions">
                                <button class="btn-danger" onclick="deleteWeeklyTask(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-box-archive"></i> أرشيف الأسابيع الماضية</div>
                </div>
                <div>
                    ${appData.weeklyIndependentTasks.archives.length === 0 ? '<p style="color:var(--text-sub); font-size:13px;">لا يوجد أرشيف أسبوعي محفوظ حتى الآن.</p>' : ''}
                    ${appData.weeklyIndependentTasks.archives.map((arch) => `
                        <div style="background:var(--bg-input); border-radius:10px; padding:12px; margin-bottom:10px; border:1px solid var(--border-color);">
                            <div style="font-weight:700; margin-bottom:6px; color:var(--secondary);">📅 أرشيف بتاريخ: ${arch.date}</div>
                            <ul style="padding-right:20px; font-size:13px; color:var(--text-sub);">
                                ${arch.tasks.map(t => `<li>${t.done ? '✅' : '❌'} ${t.title} (${t.day || 'عام'})</li>`).join('')}
                            </ul>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'categorized') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-list-check"></i> المهام (شخصية / البيت / الأطفال)</div>
                    <button class="btn-primary" onclick="openAddCategorizedTaskModal()"><i class="fa-solid fa-plus"></i> إضافة مهمة جديدة</button>
                </div>
                <div class="item-list">
                    ${appData.categorizedTasks.length === 0 ? getEmptyState('لا توجد مهام مضافة بعد.') : ''}
                    ${appData.categorizedTasks.map((task, idx) => `
                        <div class="list-item ${task.done ? 'completed' : ''}">
                            <div class="custom-check ${task.done ? 'checked' : ''}" onclick="toggleCategorizedTask(${idx})"><i class="fa-solid fa-check"></i></div>
                            <div class="item-content">
                                <div class="item-title">${sanitize(task.title)} <span class="badge">${sanitize(task.category)}</span></div>
                                <div class="item-meta">تاريخ / توقيت التذكير: ${sanitize(task.reminderTime || 'غير محدد')}</div>
                            </div>
                            <div class="item-actions">
                                <button class="icon-btn" onclick="exportToICS(appData.categorizedTasks[${idx}].title, 'تذكير بمهمة')" title="تصدير للتقويم"><i class="fa-solid fa-bell"></i></button>
                                <button class="btn-danger" onclick="deleteCategorizedTask(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// Tasks Actions
function openAddGoalModal() {
    openModal('إضافة هدف جديد', `
        <div class="form-group">
            <label class="form-label">عنوان الهدف</label>
            <input type="text" id="goal-title" class="form-control" placeholder="مثال: حفظ سورة البقرة">
        </div>
        <div class="form-group">
            <label class="form-label">مستوى الهدف</label>
            <select id="goal-level" class="form-control">
                <option value="سنة">سنوي</option>
                <option value="شهر">شهري</option>
                <option value="أسبوع">أسبوعي</option>
                <option value="يوم">يومي</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">تاريخ الاستهداف</label>
            <input type="date" id="goal-date" class="form-control">
        </div>
        <div class="form-group">
            <label class="form-label">نسبة الإنجاز الحالية (%)</label>
            <input type="number" id="goal-progress" class="form-control" min="0" max="100" value="0">
        </div>
        <div class="form-group">
            <label class="form-label">تفاصيل وملاحظات</label>
            <textarea id="goal-details" class="form-control" placeholder="تفاصيل الخطة..."></textarea>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveGoal()"><i class="fa-solid fa-check"></i> حفظ الهدف</button>
    `);
}

function saveGoal(editIdx = null) {
    const title = document.getElementById('goal-title').value.trim();
    const level = document.getElementById('goal-level').value;
    const targetDate = document.getElementById('goal-date').value;
    const progress = parseInt(document.getElementById('goal-progress').value || '0');
    const details = document.getElementById('goal-details').value.trim();

    if (!title) return alert('الرجاء كتابة عنوان الهدف!');

    const item = { id: Date.now(), title, level, targetDate, progress, details };
    if (editIdx !== null) {
        appData.goalsCascade[editIdx] = item;
    } else {
        appData.goalsCascade.push(item);
    }
    saveAppData();
    closeModal();
    renderCurrentView();
}

function openEditGoalModal(idx) {
    const g = appData.goalsCascade[idx];
    openModal('تعديل الهدف', `
        <div class="form-group">
            <label class="form-label">عنوان الهدف</label>
            <input type="text" id="goal-title" class="form-control" value="${g.title}">
        </div>
        <div class="form-group">
            <label class="form-label">مستوى الهدف</label>
            <select id="goal-level" class="form-control">
                <option value="سنة" ${g.level==='سنة'?'selected':''}>سنوي</option>
                <option value="شهر" ${g.level==='شهر'?'selected':''}>شهري</option>
                <option value="أسبوع" ${g.level==='أسبوع'?'selected':''}>أسبوعي</option>
                <option value="يوم" ${g.level==='يوم'?'selected':''}>يومي</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">تاريخ الاستهداف</label>
            <input type="date" id="goal-date" class="form-control" value="${g.targetDate || ''}">
        </div>
        <div class="form-group">
            <label class="form-label">نسبة الإنجاز (%)</label>
            <input type="number" id="goal-progress" class="form-control" min="0" max="100" value="${g.progress || 0}">
        </div>
        <div class="form-group">
            <label class="form-label">تفاصيل وملاحظات</label>
            <textarea id="goal-details" class="form-control">${g.details || ''}</textarea>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveGoal(${idx})"><i class="fa-solid fa-check"></i> حفظ التحديثات</button>
    `);
}

function deleteGoal(idx) {
    if (confirm('هل أنتِ متأكدة من حذف هذا الهدف؟')) {
        appData.goalsCascade.splice(idx, 1);
        saveAppData();
        renderCurrentView();
    }
}

function openAddWeeklyTaskModal() {
    openModal('إضافة مهمة أسبوعية مستقلة', `
        <div class="form-group">
            <label class="form-label">عنوان المهمة</label>
            <input type="text" id="weekly-title" class="form-control" placeholder="مثال: تنظيف المطبخ العميق">
        </div>
        <div class="form-group">
            <label class="form-label">اليوم المستهدف</label>
            <select id="weekly-day" class="form-control">
                <option value="الأحد">الأحد</option>
                <option value="الأثنين">الأثنين</option>
                <option value="الثلاثاء">الثلاثاء</option>
                <option value="الأربعاء">الأربعاء</option>
                <option value="الخميس">الخميس</option>
                <option value="الجمعة">الجمعة</option>
                <option value="السبت">السبت</option>
            </select>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveWeeklyTask()"><i class="fa-solid fa-plus"></i> إضافة للمستقل</button>
    `);
}

function saveWeeklyTask() {
    const title = document.getElementById('weekly-title').value.trim();
    const day = document.getElementById('weekly-day').value;
    if (!title) return alert('برجاء إدخال عنوان المهمة');

    appData.weeklyIndependentTasks.currentWeek.push({ id: Date.now(), title, day, done: false });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function toggleWeeklyTask(idx) {
    appData.weeklyIndependentTasks.currentWeek[idx].done = !appData.weeklyIndependentTasks.currentWeek[idx].done;
    saveAppData();
    renderCurrentView();
}

function deleteWeeklyTask(idx) {
    appData.weeklyIndependentTasks.currentWeek.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function archiveCurrentWeek() {
    if (appData.weeklyIndependentTasks.currentWeek.length === 0) {
        return alert('الجدول الأسبوعي فارغ بالفعل!');
    }
    if (confirm('هل ترغبين بأرشفة الأسبوع الحالي وبدء أسبوع جديد نظيف؟')) {
        const dateStr = new Date().toLocaleDateString('ar-SA');
        appData.weeklyIndependentTasks.archives.unshift({
            date: dateStr,
            tasks: [...appData.weeklyIndependentTasks.currentWeek]
        });
        appData.weeklyIndependentTasks.currentWeek = [];
        saveAppData();
        renderCurrentView();
    }
}

function openAddCategorizedTaskModal() {
    openModal('إضافة مهمة مقسمة', `
        <div class="form-group">
            <label class="form-label">عنوان المهمة</label>
            <input type="text" id="cat-task-title" class="form-control" placeholder="مثال: تحضير وجبة الغداء">
        </div>
        <div class="form-group">
            <label class="form-label">التصنيف</label>
            <select id="cat-task-category" class="form-control">
                <option value="شخصي">شخصي 🌸</option>
                <option value="بيت">البيت والمطبخ 🏠</option>
                <option value="أطفال">الأطفال 👶</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">وقت/تاريخ التذكير</label>
            <input type="text" id="cat-task-time" class="form-control" placeholder="مثال: 05:00 مساءً">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveCategorizedTask()"><i class="fa-solid fa-plus"></i> إضافة المهمة</button>
    `);
}

function saveCategorizedTask() {
    const title = document.getElementById('cat-task-title').value.trim();
    const category = document.getElementById('cat-task-category').value;
    const reminderTime = document.getElementById('cat-task-time').value.trim();
    if (!title) return alert('الرجاء إدخال عنوان المهمة!');

    appData.categorizedTasks.push({ id: Date.now(), title, category, reminderTime, done: false });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function toggleCategorizedTask(idx) {
    appData.categorizedTasks[idx].done = !appData.categorizedTasks[idx].done;
    saveAppData();
    renderCurrentView();
}

function deleteCategorizedTask(idx) {
    appData.categorizedTasks.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}


/* ==========================================================================
   2. HEALTH & FITNESS (التمارين + الأدوية + العناية بالبشرة)
   ========================================================================== */
function renderHealthView(container) {
    let html = `
        <div class="sub-nav">
            <div class="sub-pill ${currentSubTab==='workouts'?'active':''}" onclick="setSubTab('workouts')"><i class="fa-solid fa-dumbbell"></i> جدول التمارين والعضلات</div>
            <div class="sub-pill ${currentSubTab==='meds'?'active':''}" onclick="setSubTab('meds')"><i class="fa-solid fa-pills"></i> الأدوية والمكملات</div>
            <div class="sub-pill ${currentSubTab==='beauty'?'active':''}" onclick="setSubTab('beauty')"><i class="fa-solid fa-spa"></i> العناية بالبشرة والشعر</div>
        </div>
    `;

    if (currentSubTab === 'workouts') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-person-running"></i> جدول تمارين الأسبوع وتتبع العضلات</div>
                    <button class="btn-primary" onclick="openAddWorkoutModal()"><i class="fa-solid fa-plus"></i> إضافة تمرين جديد</button>
                </div>
                <div class="grid-2">
                    ${appData.workouts.length === 0 ? getEmptyState('لم يتم إضافة أي تمارين رياضية بعد.') : ''}
                    ${appData.workouts.map((w, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            ${w.photo ? `<img src="${sanitize(w.photo)}" style="width:100%; height:140px; object-fit:cover; border-radius:10px; margin-bottom:10px;">` : ''}
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">${sanitize(w.muscleName)} (${sanitize(w.day)})</div>
                                <button class="btn-danger" onclick="deleteWorkout(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            <p style="font-size:13px; color:var(--text-sub); margin-top:4px;"><strong>طريقة التدريب:</strong> ${sanitize(w.technique || 'غير مدونة')}</p>
                            <div class="item-meta" style="margin-top:8px;">
                                <span class="badge">الجولات: ${Number(w.sets) || 0}</span>
                                <span class="badge" style="background:rgba(6,182,212,0.15); color:var(--secondary);">العدات: ${Number(w.reps) || 0}</span>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'meds') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-capsules"></i> جدول الأدوية والمكملات الغذائية</div>
                    <button class="btn-primary" onclick="openAddMedModal()"><i class="fa-solid fa-plus"></i> إضافة دواء/مكمل</button>
                </div>
                <div class="item-list">
                    ${appData.medications.length === 0 ? getEmptyState('لا توجد أدوية أو مكملات مضافة.') : ''}
                    ${appData.medications.map((m, idx) => `
                        <div class="list-item ${m.taken ? 'completed' : ''}">
                            <div class="custom-check ${m.taken ? 'checked' : ''}" onclick="toggleMedTaken(${idx})"><i class="fa-solid fa-check"></i></div>
                            <div class="item-content">
                                <div class="item-title">${sanitize(m.name)}</div>
                                <div class="item-meta">⏰ التوقيت والجرعة: ${sanitize(m.time)} | ${sanitize(m.dosage || '')}</div>
                                <div style="font-size:12px; color:var(--text-sub);">${sanitize(m.notes || '')}</div>
                            </div>
                            <div class="item-actions">
                                <button class="icon-btn" onclick="exportToICS(appData.medications[${idx}].name, 'موعد دواء')" title="تصدير تذكير"><i class="fa-solid fa-bell"></i></button>
                                <button class="btn-danger" onclick="deleteMed(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'beauty') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-wand-magic-sparkles"></i> منتجات العناية بالبشرة والشعر</div>
                    <button class="btn-primary" onclick="openAddBeautyModal()"><i class="fa-solid fa-plus"></i> إضافة منتج/روتين</button>
                </div>
                <div class="grid-2">
                    ${appData.beautyProducts.length === 0 ? getEmptyState('لا توجد منتجات عناية مضافة.') : ''}
                    ${appData.beautyProducts.map((b, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">${sanitize(b.name)}</div>
                                <button class="btn-danger" onclick="deleteBeauty(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            <span class="badge" style="margin-top:4px;">${sanitize(b.type || 'روتين يومي')}</span>
                            <p style="font-size:13px; color:var(--text-sub); margin-top:8px;">${sanitize(b.instructions || '')}</p>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// Health Modal Functions
function openAddWorkoutModal() {
    openModal('إضافة تمرين رياضي جديد', `
        <div class="form-group">
            <label class="form-label">العضلة / اسم التمرين</label>
            <input type="text" id="w-muscle" class="form-control" placeholder="مثال: عضلات الظهر">
        </div>
        <div class="form-group">
            <label class="form-label">اليوم المستهدف</label>
            <select id="w-day" class="form-control">
                <option value="الأحد">الأحد</option>
                <option value="الأثنين">الأثنين</option>
                <option value="الثلاثاء">الثلاثاء</option>
                <option value="الأربعاء">الأربعاء</option>
                <option value="الخميس">الخميس</option>
                <option value="الجمعة">الجمعة</option>
                <option value="السبت">السبت</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">طريقة وأسلوب التمرين</label>
            <input type="text" id="w-tech" class="form-control" placeholder="مثال: سحب بار علوي (4 جولات)">
        </div>
        <div style="display:flex; gap:10px;">
            <div class="form-group" style="flex:1;">
                <label class="form-label">عدد الجولات</label>
                <input type="number" id="w-sets" class="form-control" value="4">
            </div>
            <div class="form-group" style="flex:1;">
                <label class="form-label">عدد العدات</label>
                <input type="number" id="w-reps" class="form-control" value="12">
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">رابط صورة التمرين (اختياري)</label>
            <input type="text" id="w-photo" class="form-control" placeholder="https://example.com/image.jpg">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveWorkout()"><i class="fa-solid fa-check"></i> حفظ التمرين</button>
    `);
}

function saveWorkout() {
    const muscleName = document.getElementById('w-muscle').value.trim();
    const day = document.getElementById('w-day').value;
    const technique = document.getElementById('w-tech').value.trim();
    const sets = parseInt(document.getElementById('w-sets').value || '0');
    const reps = parseInt(document.getElementById('w-reps').value || '0');
    const photo = document.getElementById('w-photo').value.trim();

    if (!muscleName) return alert('برجاء كتابة اسم التمرين أو العضلة');

    appData.workouts.push({ id: Date.now(), muscleName, day, technique, sets, reps, photo });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteWorkout(idx) {
    appData.workouts.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function openAddMedModal() {
    openModal('إضافة دواء أو مكمل', `
        <div class="form-group">
            <label class="form-label">اسم الدواء/المكمل</label>
            <input type="text" id="med-name" class="form-control" placeholder="مثال: فيتامين د3">
        </div>
        <div class="form-group">
            <label class="form-label">التوقيت</label>
            <input type="text" id="med-time" class="form-control" placeholder="مثال: 09:00 صباحاً">
        </div>
        <div class="form-group">
            <label class="form-label">الجرعة</label>
            <input type="text" id="med-dosage" class="form-control" placeholder="مثال: حبة واحدة يومياً">
        </div>
        <div class="form-group">
            <label class="form-label">ملاحظات إضافية</label>
            <input type="text" id="med-notes" class="form-control" placeholder="مثال: بعد الأكل">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveMed()"><i class="fa-solid fa-check"></i> حفظ الدواء</button>
    `);
}

function saveMed() {
    const name = document.getElementById('med-name').value.trim();
    const time = document.getElementById('med-time').value.trim();
    const dosage = document.getElementById('med-dosage').value.trim();
    const notes = document.getElementById('med-notes').value.trim();

    if (!name) return alert('الرجاء كتابة اسم الدواء');

    appData.medications.push({ id: Date.now(), name, time, dosage, notes, taken: false });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function toggleMedTaken(idx) {
    appData.medications[idx].taken = !appData.medications[idx].taken;
    saveAppData();
    renderCurrentView();
}

function deleteMed(idx) {
    appData.medications.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function openAddBeautyModal() {
    openModal('إضافة منتج أو روتين عناية', `
        <div class="form-group">
            <label class="form-label">اسم المنتج/الروتين</label>
            <input type="text" id="b-name" class="form-control" placeholder="مثال: سيروم ريتينول">
        </div>
        <div class="form-group">
            <label class="form-label">نوع الروتين</label>
            <input type="text" id="b-type" class="form-control" placeholder="مثال: بشرة (مساءً) / شعر">
        </div>
        <div class="form-group">
            <label class="form-label">طريقة الاستخدام والإرشادات</label>
            <textarea id="b-instructions" class="form-control" placeholder="مثال: يوضع 3 قطرات قبل النوم..."></textarea>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveBeauty()"><i class="fa-solid fa-check"></i> حفظ الروتين</button>
    `);
}

function saveBeauty() {
    const name = document.getElementById('b-name').value.trim();
    const type = document.getElementById('b-type').value.trim();
    const instructions = document.getElementById('b-instructions').value.trim();

    if (!name) return alert('الرجاء إدخال اسم المنتج');

    appData.beautyProducts.push({ id: Date.now(), name, type, instructions });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteBeauty(idx) {
    appData.beautyProducts.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}


/* ==========================================================================
   3. HOME & KITCHEN (وصفات + مؤونة + غسيل ملابس)
   ========================================================================== */
function renderHomeView(container) {
    let html = `
        <div class="sub-nav">
            <div class="sub-pill ${currentSubTab==='recipes'?'active':''}" onclick="setSubTab('recipes')"><i class="fa-solid fa-utensils"></i> وصفات الطبخ والتفاصيل</div>
            <div class="sub-pill ${currentSubTab==='pantry'?'active':''}" onclick="setSubTab('pantry')"><i class="fa-solid fa-basket-shopping"></i> مؤونة البيت واحتياجات المطبخ</div>
            <div class="sub-pill ${currentSubTab==='laundry'?'active':''}" onclick="setSubTab('laundry')"><i class="fa-solid fa-shirt"></i> جدول غسيل الملابس والعناية</div>
        </div>
    `;

    if (currentSubTab === 'recipes') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-kitchen-set"></i> جدول وموسوعة وصفات الطبخ</div>
                    <button class="btn-primary" onclick="openAddRecipeModal()"><i class="fa-solid fa-plus"></i> إضافة وصفة جديدة</button>
                </div>
                <div class="grid-2">
                    ${appData.recipes.length === 0 ? getEmptyState('لا توجد وصفات طبخ مضافة.') : ''}
                    ${appData.recipes.map((r, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            ${r.photo ? `<img src="${sanitize(r.photo)}" style="width:100%; height:130px; object-fit:cover; border-radius:10px; margin-bottom:8px;">` : ''}
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">${sanitize(r.title)} <span class="badge">${sanitize(r.mealTime)}</span></div>
                                <button class="btn-danger" onclick="deleteRecipe(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            <div style="font-size:12px; color:var(--secondary); margin-top:4px;">⚖️ المقادير والجرامات: ${sanitize(r.weights || 'غير محدد')}</div>
                            <p style="font-size:13px; color:var(--text-sub); margin-top:6px;"><strong>المكونات:</strong> ${sanitize(r.ingredients)}</p>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'pantry') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-boxes-packing"></i> احتياجات المنزل والمطبخ والمؤونة</div>
                    <button class="btn-primary" onclick="openAddPantryModal()"><i class="fa-solid fa-plus"></i> إضافة عنصر للمؤونة</button>
                </div>
                <div class="item-list">
                    ${appData.pantryItems.length === 0 ? getEmptyState('قائمة المؤونة واحتياجات المطبخ فارغة.') : ''}
                    ${appData.pantryItems.map((p, idx) => `
                        <div class="list-item ${p.bought ? 'completed' : ''}">
                            <div class="custom-check ${p.bought ? 'checked' : ''}" onclick="togglePantryBought(${idx})"><i class="fa-solid fa-check"></i></div>
                            <div class="item-content">
                                <div class="item-title">${sanitize(p.name)} <span class="badge">${sanitize(p.category)}</span></div>
                                <div class="item-meta">الكمية/العدد: ${sanitize(p.quantity || '1')}</div>
                            </div>
                            <div class="item-actions">
                                <button class="btn-danger" onclick="deletePantryItem(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'laundry') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-jug-detergent"></i> جدول غسيل الملابس والعناية بالأقمشة</div>
                    <button class="btn-primary" onclick="openAddLaundryModal()"><i class="fa-solid fa-plus"></i> إضافة جدول غسيل</button>
                </div>
                <div class="grid-2">
                    ${appData.laundrySchedule.length === 0 ? getEmptyState('لم يتم إضافة أي جدول غسيل بعد.') : ''}
                    ${appData.laundrySchedule.map((l, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">🧺 غسيل يوم: ${sanitize(l.day)} (${sanitize(l.time)})</div>
                                <button class="btn-danger" onclick="deleteLaundry(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            <div class="item-meta" style="margin-top:6px;">
                                <span class="badge">النوع: ${sanitize(l.colorType)}</span>
                                <span class="badge" style="background:rgba(245,158,11,0.15); color:var(--accent);">القماش: ${sanitize(l.fabricType)}</span>
                            </div>
                            <p style="font-size:13px; color:var(--text-sub); margin-top:8px;"><strong>المواد والطريقة:</strong> ${sanitize(l.method)}</p>
                            <button class="btn-secondary" style="margin-top:8px;" onclick="exportToICS(appData.laundrySchedule[${idx}].colorType, 'موعد غسيل')"><i class="fa-solid fa-bell"></i> تذكير بالتقويم</button>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// Home Modals & Actions
function openAddRecipeModal() {
    openModal('إضافة وصفة طبخ جديدة', `
        <div class="form-group">
            <label class="form-label">اسم الوصفة</label>
            <input type="text" id="recipe-title" class="form-control" placeholder="مثال: كبسة دجاج">
        </div>
        <div class="form-group">
            <label class="form-label">الوجبة</label>
            <select id="recipe-meal" class="form-control">
                <option value="إفطار">إفطار</option>
                <option value="غداء">غداء</option>
                <option value="عشاء">عشاء</option>
                <option value="حلى وسناك">حلى وسناك</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">المكونات الرئيسية</label>
            <textarea id="recipe-ingredients" class="form-control" placeholder="أرز، دجاج، بهارات..."></textarea>
        </div>
        <div class="form-group">
            <label class="form-label">الجرامات والأوزان</label>
            <input type="text" id="recipe-weights" class="form-control" placeholder="مثال: 500g دجاج | 2 كوب أرز">
        </div>
        <div class="form-group">
            <label class="form-label">رابط الصورة (اختياري)</label>
            <input type="text" id="recipe-photo" class="form-control" placeholder="https://example.com/food.jpg">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveRecipe()"><i class="fa-solid fa-check"></i> حفظ الوصفة</button>
    `);
}

function saveRecipe() {
    const title = document.getElementById('recipe-title').value.trim();
    const mealTime = document.getElementById('recipe-meal').value;
    const ingredients = document.getElementById('recipe-ingredients').value.trim();
    const weights = document.getElementById('recipe-weights').value.trim();
    const photo = document.getElementById('recipe-photo').value.trim();

    if (!title) return alert('برجاء كتابة عنوان الوصفة!');

    appData.recipes.push({ id: Date.now(), title, mealTime, ingredients, weights, photo });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteRecipe(idx) {
    appData.recipes.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function openAddPantryModal() {
    openModal('إضافة عنصر للمؤونة والمطبخ', `
        <div class="form-group">
            <label class="form-label">اسم العنصر</label>
            <input type="text" id="pantry-name" class="form-control" placeholder="مثال: زيت زيتون">
        </div>
        <div class="form-group">
            <label class="form-label">التصنيف</label>
            <select id="pantry-cat" class="form-control">
                <option value="طعام ومواد">طعام ومواد غذائية</option>
                <option value="زيوت وبهارات">زيوت وبهارات</option>
                <option value="مكسرات ومجففات">مكسرات ومجففات</option>
                <option value="منظفات ومستلزمات">منظفات ومستلزمات منزلية</option>
                <option value="غاز ومستلزمات">غاز وأجهزة</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">الكمية/العدد</label>
            <input type="text" id="pantry-qty" class="form-control" placeholder="مثال: 2 لتر / عبوة واحدة">
        </div>
        <button class="btn-primary" style="width:100%" onclick="savePantryItem()"><i class="fa-solid fa-check"></i> حفظ بالمؤونة</button>
    `);
}

function savePantryItem() {
    const name = document.getElementById('pantry-name').value.trim();
    const category = document.getElementById('pantry-cat').value;
    const quantity = document.getElementById('pantry-qty').value.trim();

    if (!name) return alert('الرجاء إدخال اسم العنصر');

    appData.pantryItems.push({ id: Date.now(), name, category, quantity, bought: false });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function togglePantryBought(idx) {
    appData.pantryItems[idx].bought = !appData.pantryItems[idx].bought;
    saveAppData();
    renderCurrentView();
}

function deletePantryItem(idx) {
    appData.pantryItems.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function openAddLaundryModal() {
    openModal('إضافة جدول غسيل جديد', `
        <div class="form-group">
            <label class="form-label">يوم الغسيل</label>
            <select id="laund-day" class="form-control">
                <option value="الأحد">الأحد</option>
                <option value="الأثنين">الأثنين</option>
                <option value="الثلاثاء">الثلاثاء</option>
                <option value="الأربعاء">الأربعاء</option>
                <option value="الخميس">الخميس</option>
                <option value="الجمعة">الجمعة</option>
                <option value="السبت">السبت</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">الوقت</label>
            <input type="text" id="laund-time" class="form-control" placeholder="مثال: 10:00 صباحاً">
        </div>
        <div class="form-group">
            <label class="form-label">نوع الملابس (ملونة / بيضاء)</label>
            <input type="text" id="laund-color" class="form-control" placeholder="مثال: ملابس بيضاء">
        </div>
        <div class="form-group">
            <label class="form-label">نوع القماش</label>
            <input type="text" id="laund-fabric" class="form-control" placeholder="مثال: قطنيات / ناعم">
        </div>
        <div class="form-group">
            <label class="form-label">المواد وطريقة الغسيل</label>
            <input type="text" id="laund-method" class="form-control" placeholder="مثال: غسيل دافئ + مطهر ملابس">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveLaundry()"><i class="fa-solid fa-check"></i> حفظ الجدول</button>
    `);
}

function saveLaundry() {
    const day = document.getElementById('laund-day').value;
    const time = document.getElementById('laund-time').value.trim();
    const colorType = document.getElementById('laund-color').value.trim();
    const fabricType = document.getElementById('laund-fabric').value.trim();
    const method = document.getElementById('laund-method').value.trim();

    if (!colorType) return alert('الرجاء إدخال نوع الملابس');

    appData.laundrySchedule.push({ id: Date.now(), day, time, colorType, fabricType, method });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteLaundry(idx) {
    appData.laundrySchedule.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}


/* ==========================================================================
   4. BUDGET & FINANCES (الميزانية الكاملة + الإضافات)
   ========================================================================== */
function renderBudgetView(container) {
    const totalSalary = Number(appData.finances.salary || 0);
    const totalExpenses = appData.finances.items.reduce((sum, item) => sum + Number(item.amount || 0), 0);
    const remaining = totalSalary - totalExpenses;

    let html = `
        <div class="card" style="background: linear-gradient(135deg, #111c3a, #1a2954);">
            <div class="card-header">
                <div class="card-title"><i class="fa-solid fa-sack-dollar"></i> ملخص الميزانية والمالية الشهرية</div>
                <button class="btn-secondary" onclick="openSetSalaryModal()"><i class="fa-solid fa-pen"></i> تحديد الراتب</button>
            </div>
            <div class="grid-3" style="margin-top:10px;">
                <div style="background:var(--bg-input); padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border-color);">
                    <div style="font-size:12px; color:var(--text-sub);">إجمالي الراتب/الدخل</div>
                    <div style="font-size:22px; font-weight:800; color:var(--primary); margin-top:4px;">${totalSalary.toLocaleString()} ر.س</div>
                </div>
                <div style="background:var(--bg-input); padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border-color);">
                    <div style="font-size:12px; color:var(--text-sub);">إجمالي النفقات والالتزامات</div>
                    <div style="font-size:22px; font-weight:800; color:var(--rose); margin-top:4px;">${totalExpenses.toLocaleString()} ر.س</div>
                </div>
                <div style="background:var(--bg-input); padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border-color);">
                    <div style="font-size:12px; color:var(--text-sub);">المتبقي الصافي</div>
                    <div style="font-size:22px; font-weight:800; color:var(--secondary); margin-top:4px;">${remaining.toLocaleString()} ر.س</div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <div class="card-title"><i class="fa-solid fa-receipt"></i> بنود الالتزامات والمصاريف والاشتراكات</div>
                <button class="btn-primary" onclick="openAddBudgetItemModal()"><i class="fa-solid fa-plus"></i> إضافة بند مالي</button>
            </div>
            <div class="item-list">
                ${appData.finances.items.length === 0 ? getEmptyState('لا توجد بنود مالية مضافة بعد.') : ''}
                ${appData.finances.items.map((item, idx) => `
                    <div class="list-item">
                        <div class="item-content">
                            <div class="item-title">${sanitize(item.title)} <span class="badge">${sanitize(item.category)}</span></div>
                            <div class="item-meta">المبلغ: ${Number(item.amount || 0).toLocaleString()} ر.س | تاريخ التجديد/الدفع: ${sanitize(item.dueDate || 'غير محدد')}</div>
                        </div>
                        <div class="item-actions">
                            <button class="btn-danger" onclick="deleteBudgetItem(${idx})"><i class="fa-solid fa-trash"></i></button>
                        </div>
                    </div>
                `).join('')}
            </div>
        </div>
    `;

    container.innerHTML = html;
}

function openSetSalaryModal() {
    openModal('تحديد إجمالي الراتب الشهري', `
        <div class="form-group">
            <label class="form-label">إجمالي دخل الشهر (ريال)</label>
            <input type="number" id="salary-amount" class="form-control" value="${appData.finances.salary || 0}">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveSalary()"><i class="fa-solid fa-check"></i> حفظ الراتب</button>
    `);
}

function saveSalary() {
    const val = parseFloat(document.getElementById('salary-amount').value || '0');
    appData.finances.salary = val;
    saveAppData();
    closeModal();
    renderCurrentView();
}

function openAddBudgetItemModal() {
    openModal('إضافة بند مالي جديد', `
        <div class="form-group">
            <label class="form-label">عنوان البند</label>
            <input type="text" id="budget-title" class="form-control" placeholder="مثال: فاتورة الكهرباء والماء">
        </div>
        <div class="form-group">
            <label class="form-label">التصنيف</label>
            <select id="budget-cat" class="form-control">
                <option value="فواتير">فواتير ثابته 📄</option>
                <option value="تسوق">تسوق ومقاضي 🛒</option>
                <option value="ادخار">ادخار واستثمار 💎</option>
                <option value="تعليم">تعليم وأطفال 📚</option>
                <option value="اشتراكات">اشتراكات وترفيه 🎬</option>
                <option value="سفر">سفر ورحلات ✈️</option>
            </select>
        </div>
        <div class="form-group">
            <label class="form-label">المبلغ (ريال)</label>
            <input type="number" id="budget-amount" class="form-control" placeholder="500">
        </div>
        <div class="form-group">
            <label class="form-label">تاريخ الاستحقاق/التجديد</label>
            <input type="text" id="budget-due" class="form-control" placeholder="مثال: 25 من كل شهر">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveBudgetItem()"><i class="fa-solid fa-check"></i> إضافة البند</button>
    `);
}

function saveBudgetItem() {
    const title = document.getElementById('budget-title').value.trim();
    const category = document.getElementById('budget-cat').value;
    const amount = parseFloat(document.getElementById('budget-amount').value || '0');
    const dueDate = document.getElementById('budget-due').value.trim();

    if (!title) return alert('الرجاء كتابة عنوان البند');

    appData.finances.items.push({ id: Date.now(), title, category, amount, dueDate });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteBudgetItem(idx) {
    appData.finances.items.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}


/* ==========================================================================
   5. READING, NOTES & AUDIO JOURNAL (القراءة + الملاحظات + المذكرات)
   ========================================================================== */
function renderReadingView(container) {
    let html = `
        <div class="sub-nav">
            <div class="sub-pill ${currentSubTab==='quran'?'active':''}" onclick="setSubTab('quran')"><i class="fa-solid fa-book-quran"></i> متتبع الورد القرآني والكتب</div>
            <div class="sub-pill ${currentSubTab==='audio'?'active':''}" onclick="setSubTab('audio')"><i class="fa-solid fa-microphone"></i> المذكرات الصوتية واليوميات</div>
            <div class="sub-pill ${currentSubTab==='notes'?'active':''}" onclick="setSubTab('notes')"><i class="fa-solid fa-note-sticky"></i> الملاحظات العامة والأفكار</div>
        </div>
    `;

    if (currentSubTab === 'quran') {
        const page = appData.booksAndQuran.quranPage || 1;
        const quranPct = Math.round((page / 604) * 100);

        html += `
            <div class="card" style="background: linear-gradient(135deg, #111c3a, #162a5c);">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-book-quran" style="color:var(--primary);"></i> متتبع الورد القرآني اليومي</div>
                    <button class="btn-primary" onclick="incrementQuranPage()"><i class="fa-solid fa-plus"></i> +1 صفحة</button>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-top:10px;">
                    <div>
                        <div style="font-size:13px; color:var(--text-sub);">الصفحة الحالية من المصحف (604 صفحة):</div>
                        <div style="font-size:28px; font-weight:800; color:var(--primary);">${page}</div>
                    </div>
                    <button class="btn-secondary" onclick="openSetQuranPageModal()"><i class="fa-solid fa-pen"></i> تعديل رقم الصفحة</button>
                </div>
                <div class="progress-bar-bg" style="margin-top:14px;"><div class="progress-bar-fill" style="width: ${quranPct}%"></div></div>
                <div style="font-size:12px; color:var(--secondary); text-align:left; margin-top:4px;">نسبة الختمة: ${quranPct}%</div>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-book"></i> قائمة الكتب ومعدل القراءة</div>
                    <button class="btn-primary" onclick="openAddBookModal()"><i class="fa-solid fa-plus"></i> إضافة كتاب جديد</button>
                </div>
                <div class="item-list">
                    ${appData.booksAndQuran.books.length === 0 ? getEmptyState('لا توجد كتب مضافة في القائمة.') : ''}
                    ${appData.booksAndQuran.books.map((b, idx) => {
                        const pct = Math.min(100, Math.round(((b.currentPage || 0) / (b.totalPages || 1)) * 100));
                        return `
                            <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                                <div style="display:flex; justify-content:space-between; width:100%;">
                                    <div class="item-title">${sanitize(b.title)} <span class="badge">${sanitize(b.author || 'كاتب غير محدد')}</span></div>
                                    <div class="item-actions">
                                        <button class="icon-btn" onclick="openUpdateBookProgressModal(${idx})" title="تحديث القراءة"><i class="fa-solid fa-bookmark"></i></button>
                                        <button class="btn-danger" onclick="deleteBook(${idx})"><i class="fa-solid fa-trash"></i></button>
                                    </div>
                                </div>
                                <div class="item-meta" style="margin-top:4px;">
                                    <span>الصفحات: ${b.currentPage || 0} / ${b.totalPages || 0} (${pct}%)</span>
                                </div>
                                <div class="progress-bar-bg" style="width:100%;"><div class="progress-bar-fill" style="width: ${pct}%"></div></div>
                            </div>
                        `;
                    }).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'audio') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-microphone-lines"></i> مسجل المذكرات الصوتية واليوميات</div>
                </div>
                <div class="audio-recorder-box">
                    <p style="font-size:13px; color:var(--text-sub);">اضغطي على الزر لبدء تسجيل ملاحظتك أو فكرتك بصوتك 🎙️</p>
                    <div style="display:flex; gap:10px; align-items:center;">
                        <button id="record-btn" class="btn-primary" onclick="toggleAudioRecording()">
                            <i class="fa-solid fa-microphone"></i> <span id="record-btn-text">بدء التسجيل الصوتي</span>
                        </button>
                        <span id="recording-timer" style="font-weight:700; color:var(--rose); display:none;">🔴 جارٍ التسجيل...</span>
                    </div>
                    <div id="audio-preview-container" style="display:none; margin-top:10px;">
                        <audio id="audio-player" controls style="width:100%; margin-bottom:8px;"></audio>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-journal-whills"></i> سجل اليوميات والمذكرات المحفوظة</div>
                    <button class="btn-primary" onclick="openAddJournalModal()"><i class="fa-solid fa-plus"></i> إضافة تدوينة نصية</button>
                </div>
                <div class="item-list">
                    ${appData.journalEntries.length === 0 ? getEmptyState('لا توجد مذكرات أو يوميات مضافة بعد.') : ''}
                    ${appData.journalEntries.map((j, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">${sanitize(j.title)} <span class="badge">${sanitize(j.date || '')}</span></div>
                                <button class="btn-danger" onclick="deleteJournal(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            ${j.audioUrl ? `<audio controls src="${sanitize(j.audioUrl)}" style="width:100%; margin-top:8px;"></audio>` : ''}
                            ${j.content ? `<p style="font-size:13.5px; color:var(--text-sub); margin-top:6px; line-height:1.5;">${sanitize(j.content)}</p>` : ''}
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    } else if (currentSubTab === 'notes') {
        html += `
            <div class="card">
                <div class="card-header">
                    <div class="card-title"><i class="fa-solid fa-note-sticky"></i> الملاحظات والأفكار العامة</div>
                    <button class="btn-primary" onclick="openAddNoteModal()"><i class="fa-solid fa-plus"></i> إضافة ملاحظة</button>
                </div>
                <div class="grid-2">
                    ${appData.generalNotes.length === 0 ? getEmptyState('لا توجد ملاحظات مضافة.') : ''}
                    ${appData.generalNotes.map((n, idx) => `
                        <div class="list-item" style="flex-direction:column; align-items:flex-start;">
                            <div style="display:flex; justify-content:space-between; width:100%;">
                                <div class="item-title">${sanitize(n.title)} <span class="badge">${sanitize(n.category || 'عام')}</span></div>
                                <button class="btn-danger" onclick="deleteNote(${idx})"><i class="fa-solid fa-trash"></i></button>
                            </div>
                            <p style="font-size:13px; color:var(--text-sub); margin-top:8px; white-space:pre-wrap;">${sanitize(n.text)}</p>
                            <div style="font-size:11px; color:var(--secondary); margin-top:8px;">التاريخ: ${sanitize(n.date || '')}</div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    }

    container.innerHTML = html;
}

// Quran & Reading Actions
function incrementQuranPage() {
    if (!appData.booksAndQuran.quranPage) appData.booksAndQuran.quranPage = 1;
    if (appData.booksAndQuran.quranPage < 604) appData.booksAndQuran.quranPage += 1;
    saveAppData();
    renderCurrentView();
}

function openSetQuranPageModal() {
    openModal('تعديل رقم الصفحة الحالية', `
        <div class="form-group">
            <label class="form-label">رقم الصفحة من المصحف (1 - 604)</label>
            <input type="number" id="q-page" class="form-control" min="1" max="604" value="${appData.booksAndQuran.quranPage || 1}">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveQuranPage()"><i class="fa-solid fa-check"></i> تحديث الصفحة</button>
    `);
}

function saveQuranPage() {
    const val = parseInt(document.getElementById('q-page').value || '1');
    appData.booksAndQuran.quranPage = Math.max(1, Math.min(604, val));
    saveAppData();
    closeModal();
    renderCurrentView();
}

function openAddBookModal() {
    openModal('إضافة كتاب جديد للقائمة', `
        <div class="form-group">
            <label class="form-label">عنوان الكتاب</label>
            <input type="text" id="book-title" class="form-control" placeholder="مثال: لأنك الله">
        </div>
        <div class="form-group">
            <label class="form-label">المؤلف</label>
            <input type="text" id="book-author" class="form-control" placeholder="اسم الكاتب">
        </div>
        <div style="display:flex; gap:10px;">
            <div class="form-group" style="flex:1;">
                <label class="form-label">إجمالي الصفحات</label>
                <input type="number" id="book-total" class="form-control" placeholder="200">
            </div>
            <div class="form-group" style="flex:1;">
                <label class="form-label">الصفحة الحالية</label>
                <input type="number" id="book-current" class="form-control" value="0">
            </div>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveBook()"><i class="fa-solid fa-check"></i> حفظ الكتاب</button>
    `);
}

function saveBook() {
    const title = document.getElementById('book-title').value.trim();
    const author = document.getElementById('book-author').value.trim();
    const totalPages = parseInt(document.getElementById('book-total').value || '100');
    const currentPage = parseInt(document.getElementById('book-current').value || '0');

    if (!title) return alert('الرجاء إدخال عنوان الكتاب');

    appData.booksAndQuran.books.push({ id: Date.now(), title, author, totalPages, currentPage });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function openUpdateBookProgressModal(idx) {
    const b = appData.booksAndQuran.books[idx];
    openModal('تحديث تقدم القراءة', `
        <div class="form-group">
            <label class="form-label">كتاب: ${b.title}</label>
            <label class="form-label">وصلت للصفحة رقم:</label>
            <input type="number" id="b-cur-page" class="form-control" min="0" max="${b.totalPages}" value="${b.currentPage || 0}">
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveBookProgress(${idx})"><i class="fa-solid fa-check"></i> تحديث الإنجاز</button>
    `);
}

function saveBookProgress(idx) {
    const val = parseInt(document.getElementById('b-cur-page').value || '0');
    appData.booksAndQuran.books[idx].currentPage = val;
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteBook(idx) {
    appData.booksAndQuran.books.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

// Audio Recording Logic using Web Audio API / MediaRecorder
let activeMediaStream = null; // Track stream to stop mic properly

async function toggleAudioRecording() {
    if (!isRecording) {
        try {
            // Check browser support
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                return alert('المتصفح لا يدعم تسجيل الصوت. استخدمي Chrome أو Safari أو Firefox.');
            }

            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            activeMediaStream = stream; // Save stream reference for cleanup

            // Pick best supported MIME type
            const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
                ? 'audio/webm;codecs=opus'
                : MediaRecorder.isTypeSupported('audio/webm')
                    ? 'audio/webm'
                    : 'audio/ogg';

            mediaRecorder = new MediaRecorder(stream, { mimeType });
            audioChunks = [];

            mediaRecorder.ondataavailable = (event) => {
                if (event.data && event.data.size > 0) audioChunks.push(event.data);
            };

            mediaRecorder.onstop = () => {
                // CRITICAL FIX: Stop all mic tracks to release microphone
                if (activeMediaStream) {
                    activeMediaStream.getTracks().forEach(track => track.stop());
                    activeMediaStream = null;
                }

                const audioBlob = new Blob(audioChunks, { type: mimeType });
                const audioUrl = URL.createObjectURL(audioBlob);
                currentRecordedAudioUrl = audioUrl;

                // Update preview player if still on same view
                const player = document.getElementById('audio-player');
                const previewBox = document.getElementById('audio-preview-container');
                if (player && previewBox) {
                    player.src = audioUrl;
                    previewBox.style.display = 'block';
                }

                // Prompt modal to save recorded audio
                openModal('حفظ المذكرة الصوتية', `
                    <div class="form-group">
                        <label class="form-label">عنوان المذكرة الصوتية</label>
                        <input type="text" id="rec-title" class="form-control" placeholder="مثال: خاطرة صباحية">
                    </div>
                    <div class="form-group">
                        <label class="form-label">ملاحظات نصية (اختياري)</label>
                        <textarea id="rec-text" class="form-control" placeholder="أفكار متعلقة بتسجيلك الصوتي..."></textarea>
                    </div>
                    <button class="btn-primary" style="width:100%" onclick="saveRecordedAudioEntry()"><i class="fa-solid fa-save"></i> حفظ المذكرة</button>
                `);
            };

            mediaRecorder.onerror = (err) => {
                console.error('MediaRecorder error:', err);
                isRecording = false;
                const btn = document.getElementById('record-btn-text');
                if (btn) btn.innerText = 'بدء التسجيل الصوتي';
                const timer = document.getElementById('recording-timer');
                if (timer) timer.style.display = 'none';
            };

            mediaRecorder.start(1000); // Collect in 1-second chunks for reliability
            isRecording = true;

            const btnText = document.getElementById('record-btn-text');
            const timer = document.getElementById('recording-timer');
            if (btnText) btnText.innerText = 'إيقاف التسجيل';
            if (timer) timer.style.display = 'inline';

        } catch (err) {
            console.error('Mic access error:', err);
            if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
                alert('تم رفض الإذن للوصول إلى الميكروفون. يرجى السماح لهذا التطبيق باستخدام المايكروفون من إعدادات المتصفح.');
            } else if (err.name === 'NotFoundError') {
                alert('لا يوجد ميكروفون متصل بالجهاز.');
            } else {
                alert('تعذر الوصول إلى الميكروفون: ' + err.message);
            }
        }
    } else {
        // Stop recording
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop();
        }
        isRecording = false;
        const btnText = document.getElementById('record-btn-text');
        const timer = document.getElementById('recording-timer');
        if (btnText) btnText.innerText = 'بدء التسجيل الصوتي';
        if (timer) timer.style.display = 'none';
    }
}

function saveRecordedAudioEntry() {
    const title = document.getElementById('rec-title').value.trim() || 'مذكرة صوتية';
    const content = document.getElementById('rec-text').value.trim();
    const date = new Date().toLocaleDateString('ar-SA');

    appData.journalEntries.unshift({
        id: Date.now(),
        title,
        type: 'صوت',
        content,
        audioUrl: currentRecordedAudioUrl,
        date
    });

    saveAppData();
    closeModal();
    renderCurrentView();
}

function openAddJournalModal() {
    openModal('إضافة تدوينة نصية جديدة', `
        <div class="form-group">
            <label class="form-label">عنوان اليوميات</label>
            <input type="text" id="j-title" class="form-control" placeholder="مثال: خاطرة المساء">
        </div>
        <div class="form-group">
            <label class="form-label">المحتوى والنص</label>
            <textarea id="j-content" class="form-control" placeholder="اكتبي يومياتك وأفكارك هنا..."></textarea>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveJournalEntry()"><i class="fa-solid fa-check"></i> حفظ اليوميات</button>
    `);
}

function saveJournalEntry() {
    const title = document.getElementById('j-title').value.trim();
    const content = document.getElementById('j-content').value.trim();
    const date = new Date().toLocaleDateString('ar-SA');

    if (!title) return alert('الرجاء إدخال عنوان اليومية');

    appData.journalEntries.unshift({
        id: Date.now(),
        title,
        type: 'نص',
        content,
        audioUrl: '',
        date
    });

    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteJournal(idx) {
    appData.journalEntries.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}

function openAddNoteModal() {
    openModal('إضافة ملاحظة جديدة', `
        <div class="form-group">
            <label class="form-label">عنوان الملاحظة</label>
            <input type="text" id="note-title" class="form-control" placeholder="مثال: وصفة أعشاب تجميلية">
        </div>
        <div class="form-group">
            <label class="form-label">التصنيف</label>
            <input type="text" id="note-cat" class="form-control" placeholder="مثال: ديكور / أفكار / شراء">
        </div>
        <div class="form-group">
            <label class="form-label">نص الملاحظة</label>
            <textarea id="note-text" class="form-control" placeholder="التفاصيل..."></textarea>
        </div>
        <button class="btn-primary" style="width:100%" onclick="saveNote()"><i class="fa-solid fa-check"></i> حفظ الملاحظة</button>
    `);
}

function saveNote() {
    const title = document.getElementById('note-title').value.trim();
    const category = document.getElementById('note-cat').value.trim();
    const text = document.getElementById('note-text').value.trim();
    const date = new Date().toLocaleDateString('ar-SA');

    if (!title) return alert('الرجاء كتابة عنوان الملاحظة');

    appData.generalNotes.unshift({ id: Date.now(), title, category, text, date });
    saveAppData();
    closeModal();
    renderCurrentView();
}

function deleteNote(idx) {
    appData.generalNotes.splice(idx, 1);
    saveAppData();
    renderCurrentView();
}


/* ==========================================================================
   6. AI ASSISTANT (مساعد Gemini 3.6 Flash الذكي)
   ========================================================================== */
function renderAIView(container) {
    // Build persisted chat HTML from aiChatHistory array
    const welcomeMsg = `<div class="chat-bubble bot">أهلاً بكِ ${sanitize(appData.settings.wifeName || 'إيمان')}! 🌸 أنا مساعدكِ الذكي المدمج بـ Gemini Flash. كيف أستطيع مساعدتكِ اليوم في تنظيم جدولكِ، وصفات الطعام، التمارين الرياضية، أو ترتيب ميزانيتكِ؟</div>`;

    const historyHtml = aiChatHistory.map(msg =>
        `<div class="chat-bubble ${msg.role}">${msg.role === 'bot' ? msg.text : sanitize(msg.text)}</div>`
    ).join('');

    let html = `
        <div class="chat-container">
            <div class="quick-prompts">
                <button class="quick-prompt-btn" onclick="sendQuickAiPrompt('اقترحي لي جدول تنظيف وتنظيم للمطبخ')">💡 جدول تنظيف للمطبخ</button>
                <button class="quick-prompt-btn" onclick="sendQuickAiPrompt('أعطيني جدول تمارين لتقوية عضلات الظهر والكتف')">🏋️ تمارين للظهر</button>
                <button class="quick-prompt-btn" onclick="sendQuickAiPrompt('اقترحي لي وجبة عشاء صحية وسريعة')">🥗 وجبة عشاء صحية</button>
                <button class="quick-prompt-btn" onclick="sendQuickAiPrompt('كيف أنظم ميزانيتي الشهرية والادخار بشكل متوازن؟')">💰 تنظيم الميزانية</button>
            </div>

            <div id="chat-messages" class="chat-messages">
                ${welcomeMsg}
                ${historyHtml}
            </div>

            <div class="chat-input-area">
                <input type="text" id="ai-input-text" class="form-control" placeholder="اسألي المساعد الذكي شيئاً..." onkeypress="handleAiKeyPress(event)">
                <button class="btn-primary" onclick="sendAiMessage()"><i class="fa-solid fa-paper-plane"></i> إرسال</button>
            </div>
        </div>
    `;

    container.innerHTML = html;

    // Auto-scroll to bottom of chat history
    const chatEl = document.getElementById('chat-messages');
    if (chatEl) chatEl.scrollTop = chatEl.scrollHeight;
}

function sendQuickAiPrompt(text) {
    const input = document.getElementById('ai-input-text');
    if (input) {
        input.value = text;
        sendAiMessage();
    }
}

function handleAiKeyPress(e) {
    if (e.key === 'Enter') sendAiMessage();
}

async function sendAiMessage() {
    const inputEl = document.getElementById('ai-input-text');
    const prompt = inputEl ? inputEl.value.trim() : '';
    if (!prompt) return;

    // Add user message to persistent history
    aiChatHistory.push({ role: 'user', text: prompt });

    const chatMessages = document.getElementById('chat-messages');
    if (!chatMessages) return;

    chatMessages.innerHTML += `<div class="chat-bubble user">${sanitize(prompt)}</div>`;
    if (inputEl) inputEl.value = '';
    chatMessages.scrollTop = chatMessages.scrollHeight;

    const loadingId = 'ai-loading-' + Date.now();
    chatMessages.innerHTML += `<div class="chat-bubble bot" id="${loadingId}">جارٍ التفكير والرد من المساعد الذكي... ⏳</div>`;
    chatMessages.scrollTop = chatMessages.scrollHeight;

    // Key priority: 1) personal key from settings, 2) shared app key, 3) none
    const personalKey = (appData.settings?.geminiApiKey || '').trim();
    const apiKey = personalKey || SHARED_APP_KEY.trim();

    if (!apiKey) {
        const fallbackReply = `مرحباً 🌸! المساعد الذكي يحتاج مفتاح Gemini API للعمل.\n\n📋 خطوات التفعيل:\n• افتحي: https://aistudio.google.com/app/apikey\n• احصلي على مفتاح مجاني (يبدأ بـ AIzaSy...)\n• أضيفيه في إعدادات التطبيق ⚙️\n\nجميع الأقسام الأخرى تعمل بدون إنترنت! 😊`;
        const loadingEl = document.getElementById(loadingId);
        if (loadingEl) loadingEl.innerText = fallbackReply;
        aiChatHistory.push({ role: 'bot', text: fallbackReply });
        chatMessages.scrollTop = chatMessages.scrollHeight;
        return;
    }

    // Supported models — newest & most capable first
    const models = [
        'gemini-2.0-flash',
        'gemini-2.0-flash-001',
        'gemini-1.5-flash',
        'gemini-1.5-flash-001'
    ];
    let reply = '';
    let success = false;

    const userName = appData.settings.wifeName || 'إيمان';
    const systemPrompt = `أنت مساعد ${userName} الشخصي الذكي المتكامل. مهمتك مساعدتها بأسلوب ودّي ومشجع في: تنظيم المهام اليومية والأسبوعية، الوصفات والمطبخ، التمارين الرياضية وتتبع العضلات، الميزانية الشهرية، العناية الشخصية بالبشرة والشعر، والقراءة. أجيبي دائماً باللغة العربية الفصحى مع استخدام نقاط وتنسيق واضح. اجعلي إجاباتك عملية ومباشرة.`;

    for (const model of models) {
        try {
            const res = await fetch(
                `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
                {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        contents: [{
                            parts: [{ text: `${systemPrompt}\n\nسؤال ${userName}: ${prompt}` }]
                        }],
                        generationConfig: {
                            temperature: 0.7,
                            maxOutputTokens: 1024
                        }
                    })
                }
            );

            if (!res.ok) {
                const errData = await res.json().catch(() => ({}));
                const errMsg = errData?.error?.message || `HTTP ${res.status}`;
                console.warn(`[AI] Model ${model} → HTTP ${res.status}:`, errMsg);

                if (res.status === 429) {
                    // Quota exceeded — try next model before giving up
                    console.warn('[AI] Quota exceeded, trying next model...');
                    continue;
                }

                if (res.status === 401 || res.status === 403) {
                    reply = `⚠️ مفتاح API غير صالح أو منتهي الصلاحية.\n\nالمفتاح الصحيح يجب أن يبدأ بـ «AIzaSy».\nاحصلي على مفتاح جديد مجاني من: https://aistudio.google.com/app/apikey\nثم أضيفيه من إعدادات التطبيق ⚙️`;
                    break;
                }

                if (res.status === 400) {
                    reply = `⚠️ خطأ في الطلب: ${errMsg}\n\nيرجى التأكد من صحة مفتاح API في الإعدادات.`;
                    break;
                }

                // Other HTTP errors — try next model
                continue;
            }

            const data = await res.json();

            if (data.candidates?.[0]?.content?.parts?.[0]?.text) {
                reply = data.candidates[0].content.parts[0].text;
                // Clean up markdown bold/bullet formatting for plain display
                reply = reply
                    .replace(/\*\*([^*]+)\*\*/g, '$1')
                    .replace(/^\*\s/gm, '• ')
                    .replace(/^##\s+/gm, '📌 ')
                    .replace(/^###\s+/gm, '→ ')
                    .trim();
                success = true;
                break;
            }

            // Empty response — try next model
            console.warn(`[AI] Model ${model} returned empty response`);

        } catch (err) {
            // Network error (offline, CORS, etc.)
            console.warn(`[AI] Model ${model} network error:`, err.message);

            if (err.name === 'TypeError' && err.message.includes('Failed to fetch')) {
                reply = `📵 لا يوجد اتصال بالإنترنت في الوقت الحالي.\n\nيمكنكِ استخدام جميع أقسام التطبيق (المهام، الصحة، المطبخ، الميزانية) بدون إنترنت. المساعد الذكي يحتاج اتصالاً للرد. 😊`;
                break;
            }
        }
    }

    // Final fallback if all models failed with quota
    if (!success && !reply) {
        reply = `عذراً 😔 المساعد الذكي مشغول حالياً (تجاوز الحد اليومي للطلبات).\n\nحاولي مرة أخرى بعد قليل أو غداً، والخطة المجانية تُجدَّد يومياً! 🔄\n\nفي غضون ذلك، استخدمي أقسام المهام والمطبخ والميزانية التي تعمل بشكل كامل.`;
    }

    const loadingEl = document.getElementById(loadingId);
    if (loadingEl) loadingEl.innerText = reply;

    // Save to persistent chat history
    aiChatHistory.push({ role: 'bot', text: reply });

    chatMessages.scrollTop = chatMessages.scrollHeight;
}



/* ==========================================================================
   7. MODAL UTILITIES, BACKUP & EXPORT SYSTEM
   ========================================================================== */
function openModal(title, contentHtml) {
    document.getElementById('modal-title-text').innerText = title;
    document.getElementById('modal-body-content').innerHTML = contentHtml;
    document.getElementById('global-modal').classList.add('active');
}

function closeModal() {
    document.getElementById('global-modal').classList.remove('active');
}

function openSettingsModal() {
    openModal('الإعدادات والبيانات الشخصية', `
        <div class="form-group">
            <label class="form-label">اسم المستخدمة</label>
            <input type="text" id="set-name" class="form-control" value="${appData.settings.wifeName || 'إيمان'}">
        </div>
        <div class="form-group">
            <label class="form-label">مفتاح Gemini API Key (مخصص)</label>
            <input type="password" id="set-api-key" class="form-control" value="${appData.settings.geminiApiKey || ''}" placeholder="أدخلي مفتاح API الخاص بكِ">
        </div>
        <button class="btn-primary" style="width:100%; margin-bottom:10px;" onclick="saveSettings()"><i class="fa-solid fa-save"></i> حفظ الإعدادات</button>
        <button class="btn-danger" style="width:100%" onclick="resetAppData()"><i class="fa-solid fa-rotate-left"></i> إعادة ضبط كافة البيانات</button>
    `);
}

function saveSettings() {
    appData.settings.wifeName = document.getElementById('set-name').value.trim() || 'إيمان';
    appData.settings.geminiApiKey = document.getElementById('set-api-key').value.trim();
    saveAppData();
    closeModal();
    alert('تم حفظ الإعدادات بنجاح!');
}

function resetAppData() {
    if (confirm('تنبيه: هل أنتِ متأكدة من مسح كافة البيانات وإعادة التطبيق للحالة الافتراضية؟\nلا يمكن التراجع عن هذا الإجراء.')) {
        localStorage.removeItem(STORAGE_KEY);
        location.reload();
    }
}

// Alias used in error fallback UI
function clearAllData() {
    resetAppData();
}

// Calendar Export Generator (.ics file download)
// Safely escape ICS text field (commas and semicolons must be escaped per RFC 5545)
function escapeICS(str) {
    return String(str || '')
        .replace(/\\/g, '\\\\')
        .replace(/;/g, '\\;')
        .replace(/,/g, '\\,')
        .replace(/\n/g, '\\n');
}

function exportToICS(title, description) {
    const start = new Date();
    const end = new Date(start.getTime() + 3600000); // +1 hour
    const formatDate = (d) => d.toISOString().replace(/-|:|\.\d+/g, '').slice(0, 15) + 'Z';
    const uid = `eman-${Date.now()}@eman-app`;

    const icsContent = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Eman Life Assistant//AR',
        'CALSCALE:GREGORIAN',
        'BEGIN:VEVENT',
        `UID:${uid}`,
        `SUMMARY:${escapeICS(title)}`,
        `DESCRIPTION:${escapeICS(description)}`,
        `DTSTART:${formatDate(start)}`,
        `DTEND:${formatDate(end)}`,
        'STATUS:CONFIRMED',
        'END:VEVENT',
        'END:VCALENDAR'
    ].join('\r\n');

    const blob = new Blob([icsContent], { type: 'text/calendar;charset=utf-8' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    // Sanitize filename: remove chars not safe for filenames
    const safeName = String(title).replace(/[^\w\u0600-\u06FF\s-]/g, '').replace(/\s+/g, '_').slice(0, 50);
    link.download = `${safeName}_reminder.ics`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    // Revoke object URL to free memory
    setTimeout(() => URL.revokeObjectURL(link.href), 1000);
}

// Backup JSON Export & Import
function exportDataJSON() {
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(appData, null, 2));
    const dlAnchor = document.createElement('a');
    dlAnchor.setAttribute("href", dataStr);
    dlAnchor.setAttribute("download", `eman_app_backup_${new Date().toISOString().slice(0,10)}.json`);
    document.body.appendChild(dlAnchor);
    dlAnchor.click();
    dlAnchor.remove();
}

function triggerImportJSON() {
    document.getElementById('import-json-input').click();
}

function importDataJSON(event) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
        try {
            const imported = JSON.parse(e.target.result);
            if (imported && typeof imported === 'object') {
                appData = imported;
                saveAppData();
                renderCurrentView();
                alert('تمت استعادة كافة البيانات بنجاح! 🎉');
            } else {
                alert('ملف البيانات غير صالح.');
            }
        } catch (err) {
            alert('حدث خطأ في قراءة ملف JSON.');
        }
    };
    reader.readAsText(file);
}

(function () {
  const STORAGE_KEY = "flutiano-projects-v3";
  const DEFAULT_THUMBNAIL = "assets/dashboard-bg.jpg";
  const toneMap = {
    gold: ["#2D2117", "#8E6238"],
    jade: ["#12211F", "#2C7D71"],
    sky: ["#122031", "#4E7FA0"],
    violet: ["#1B1830", "#6B56A5"]
  };
  const INSTRUMENT_OPTIONS = [
    "Piano",
    "Voice",
    "Drums",
    "Vietnamese bamboo flute",
    "Chinese dizi",
    "Western concert flute",
    "Vietnamese zither",
    "Chinese zither"
  ];
  const SOURCE_LIBRARY_GROUPS = [
    { key: "sheetSources", title: "Sheet Sources" },
    { key: "harmonySources", title: "Harmony Sources" },
    { key: "audioReferences", title: "Audio References" },
    { key: "additionalSources", title: "Additional Sources" }
  ];
  const INSTRUMENT_KEYWORDS = {
    "Piano": ["piano"],
    "Voice": ["voice", "vocal"],
    "Drums": ["drums", "drum", "percussion", "rhythm section"],
    "Vietnamese bamboo flute": ["vietnamese bamboo flute", "bamboo flute", "sáo trúc", "sao truc"],
    "Chinese dizi": ["chinese dizi", "dizi"],
    "Western concert flute": ["western concert flute", "concert flute", "flute"],
    "Vietnamese zither": ["vietnamese zither", "vietnamese đàn tranh", "đàn tranh", "dan tranh"],
    "Chinese zither": ["chinese zither", "chinese guzheng", "guzheng"]
  };
  const KEY_ROOT_INDEX = {
    "C": 0,
    "C#": 1,
    "Db": 1,
    "D": 2,
    "D#": 3,
    "Eb": 3,
    "E": 4,
    "F": 5,
    "F#": 6,
    "Gb": 6,
    "G": 7,
    "G#": 8,
    "Ab": 8,
    "A": 9,
    "A#": 10,
    "Bb": 10,
    "B": 11
  };
  const KEY_OPTIONS = [
    "C major", "C# major", "D major", "Eb major", "E major", "F major",
    "F# major", "G major", "Ab major", "A major", "Bb major", "B major",
    "C minor", "C# minor", "D minor", "Eb minor", "E minor", "F minor",
    "F# minor", "G minor", "Ab minor", "A minor", "Bb minor", "B minor"
  ];
  const FLAT_KEY_NAMES = new Set([
    "F major", "Bb major", "Eb major", "Ab major", "Db major", "Gb major",
    "D minor", "G minor", "C minor", "F minor", "Bb minor", "Eb minor", "Ab minor"
  ]);
  const NOTE_PALETTES = {
    sharp: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"],
    flat: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
  };
  const SCALE_INTERVALS = {
    major: [0, 2, 4, 5, 7, 9, 11],
    minor: [0, 2, 3, 5, 7, 8, 10]
  };
  const DIATONIC_QUALITIES = {
    major: ["", "m", "m", "", "", "m", "dim"],
    minor: ["m", "dim", "", "m", "m", "", ""]
  };
  const TODO_UPDATE_EVENT = "flutiano:projects-updated";
  const TODO_URGENCY_ORDER = {
    urgent: 0,
    soon: 1,
    later: 2
  };
  const DEFAULT_PRIORITY_KEYS = ["C major", "F major", "G major", "A major"];
  const LEGACY_EMOTIONAL_NOTE = "Keep the emotional direction sincere and restrained. Do not let the performance drift into bridal cliché.";

  function buildKeyTheoryLibrary() {
    return Object.fromEntries(KEY_OPTIONS.map((keyName) => {
      const [root, mode] = keyName.split(" ");
      const palette = FLAT_KEY_NAMES.has(keyName) ? NOTE_PALETTES.flat : NOTE_PALETTES.sharp;
      const baseIndex = KEY_ROOT_INDEX[root];
      const scaleNotes = SCALE_INTERVALS[mode].map((interval) => palette[(baseIndex + interval) % 12]);
      const diatonicChords = scaleNotes.map((note, index) => `${note}${DIATONIC_QUALITIES[mode][index]}`);
      const primaryChords = [diatonicChords[0], diatonicChords[3], diatonicChords[4]];
      return [keyName, {
        keyName,
        mode,
        scaleNotes,
        primaryChords,
        diatonicChords
      }];
    }));
  }

  const KEY_THEORY_LIBRARY = buildKeyTheoryLibrary();

  function slugify(value) {
    return String(value || "")
      .toLowerCase()
      .trim()
      .replace(/['"]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || `project-${Date.now()}`;
  }

  function createPlaceholderImage(title, tone, subtitle) {
    const colors = toneMap[tone] || toneMap.gold;
    const safeTitle = String(title || "Untitled");
    const safeSubtitle = String(subtitle || "The Flutiano").toUpperCase();
    const svg = `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 800">
        <defs>
          <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="${colors[0]}"/>
            <stop offset="100%" stop-color="${colors[1]}"/>
          </linearGradient>
          <linearGradient id="glow" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="rgba(255,255,255,0.04)"/>
            <stop offset="100%" stop-color="rgba(255,255,255,0.0)"/>
          </linearGradient>
        </defs>
        <rect width="1200" height="800" fill="url(#bg)"/>
        <circle cx="960" cy="140" r="210" fill="rgba(255,255,255,0.10)"/>
        <rect x="78" y="84" width="1044" height="632" rx="34" fill="rgba(6,7,11,0.16)" stroke="rgba(255,255,255,0.14)"/>
        <text x="120" y="196" fill="rgba(255,255,255,0.42)" font-family="Arial, sans-serif" font-size="26" letter-spacing="8">${safeSubtitle}</text>
        <text x="120" y="336" fill="#FFFFFF" font-family="Arial, sans-serif" font-size="82" font-weight="700">${safeTitle}</text>
        <text x="120" y="410" fill="rgba(255,255,255,0.72)" font-family="Arial, sans-serif" font-size="30">Creative System</text>
        <rect x="120" y="470" width="320" height="10" rx="5" fill="rgba(255,255,255,0.18)"/>
        <rect x="120" y="510" width="540" height="10" rx="5" fill="rgba(255,255,255,0.10)"/>
      </svg>
    `;
    return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
  }

  function createDefaultProject(input) {
    const id = input.id || slugify(input.title);
    return normalizeProject({
      id,
      title: input.title || "",
      author: input.author || "The Flutiano",
      status: input.status || "Draft",
      progress: input.progress ?? 0,
      deadline: input.deadline || "",
      category: input.category || "Cover",
      shortDescription: input.shortDescription || "",
      thumbnail: input.thumbnail || "",
      gallery: input.gallery || [],
      music: input.music || {},
      visual: input.visual || {},
      inspiration: input.inspiration || {},
      references: input.references || {},
      youtubeReferences: input.youtubeReferences || [],
      notes: input.notes || "",
      production: input.production || {},
      songWorkflow: input.songWorkflow || {},
      todos: input.todos || []
    });
  }

  function normalizeStatus(value) {
    const status = String(value || "Draft").trim();
    if (!status) return "Draft";
    if (status.toLowerCase() === "release") return "Released";
    return status;
  }

  function normalizeSelectedInstruments(rawMusic) {
    if (Array.isArray(rawMusic?.selectedInstruments)) {
      return rawMusic.selectedInstruments
        .map((item) => String(item).trim())
        .filter((item) => INSTRUMENT_OPTIONS.includes(item));
    }

    const source = String(rawMusic?.instrumentation || "").toLowerCase();
    if (!source) return [];

    return INSTRUMENT_OPTIONS.filter((label) =>
      INSTRUMENT_KEYWORDS[label].some((keyword) => source.includes(keyword))
    );
  }

  function createEmptySongWorkflow() {
    return {
      masterKey: {
        originalKey: "",
        priorityKeys: [],
        balanceNotes: "",
        finalKey: ""
      },
      sourceLibrary: {
        sheetSources: [],
        harmonySources: [],
        audioReferences: [],
        additionalSources: []
      }
    };
  }

  function normalizeTextList(list) {
    if (!Array.isArray(list)) return [];
    return list.map((item) => String(item || "").trim()).filter(Boolean);
  }

  function createEmptyProduction() {
    return {
      audio: {
        scoreOrder: ["Flute", "Piano RH", "Piano LH", "Voice"],
        supportsMidiInput: true,
        supportsXmlImport: true,
        sheetReferences: [],
        workflowNotes: "",
        iterationLoop: "",
        manualNotes: ""
      },
      image: {
        workflowNotes: "",
        referenceFrames: [],
        deliveryNotes: ""
      }
    };
  }

  function normalizeProduction(raw) {
    const empty = createEmptyProduction();
    return {
      audio: {
        scoreOrder: normalizeTextList(raw?.audio?.scoreOrder).length
          ? normalizeTextList(raw?.audio?.scoreOrder)
          : empty.audio.scoreOrder.slice(),
        supportsMidiInput: raw?.audio?.supportsMidiInput !== false,
        supportsXmlImport: raw?.audio?.supportsXmlImport !== false,
        sheetReferences: normalizeLinks(raw?.audio?.sheetReferences),
        workflowNotes: String(raw?.audio?.workflowNotes || "").trim(),
        iterationLoop: String(raw?.audio?.iterationLoop || "").trim(),
        manualNotes: String(raw?.audio?.manualNotes || "").trim()
      },
      image: {
        workflowNotes: String(raw?.image?.workflowNotes || "").trim(),
        referenceFrames: normalizeLinks(raw?.image?.referenceFrames),
        deliveryNotes: String(raw?.image?.deliveryNotes || "").trim()
      }
    };
  }

  function normalizeTodoUrgency(value) {
    const normalized = String(value || "").trim().toLowerCase();
    if (normalized === "red" || normalized === "urgent") return "urgent";
    if (normalized === "green" || normalized === "later" || normalized === "low") return "later";
    return "soon";
  }

  function createTodo(raw) {
    const completed = Boolean(raw?.completed);
    return {
      id: String(raw?.id || `todo-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`),
      text: String(raw?.text || "").trim(),
      urgency: normalizeTodoUrgency(raw?.urgency),
      completed,
      createdAt: String(raw?.createdAt || new Date().toISOString()),
      completedAt: completed ? String(raw?.completedAt || new Date().toISOString()) : ""
    };
  }

  function normalizeTodos(list) {
    if (!Array.isArray(list)) return [];
    return list
      .map((item) => createTodo(item))
      .filter((todo) => todo.text)
      .sort((left, right) => {
        if (left.completed !== right.completed) return left.completed ? 1 : -1;
        const urgencyDelta = TODO_URGENCY_ORDER[left.urgency] - TODO_URGENCY_ORDER[right.urgency];
        if (urgencyDelta !== 0) return urgencyDelta;
        const leftTime = Date.parse(left.completed ? left.completedAt : left.createdAt) || 0;
        const rightTime = Date.parse(right.completed ? right.completedAt : right.createdAt) || 0;
        return rightTime - leftTime;
      });
  }

  function normalizeSongWorkflow(raw) {
    const empty = createEmptySongWorkflow();
    const priorityKeys = Array.isArray(raw?.masterKey?.priorityKeys)
      ? raw.masterKey.priorityKeys.map((item) => String(item).trim()).filter(Boolean)
      : splitMultiline(raw?.masterKey?.priorityKeys || "");

    const sheetImages = {};
    if (raw?.sourceLibrary?.sheetImages) {
      ['musescore', 'youtube', 'website'].forEach(src => {
        if (Array.isArray(raw.sourceLibrary.sheetImages[src])) {
          sheetImages[src] = raw.sourceLibrary.sheetImages[src].map(e => ({
            label: String(e.label || "").trim(),
            url: String(e.url || "").trim(),
            images: Array.isArray(e.images) ? e.images.slice() : []
          }));
        } else {
          sheetImages[src] = [];
        }
      });
    }

    return {
      masterKey: {
        originalKey: String(raw?.masterKey?.originalKey || empty.masterKey.originalKey).trim(),
        priorityKeys,
        balanceNotes: String(raw?.masterKey?.balanceNotes || empty.masterKey.balanceNotes).trim(),
        finalKey: String(raw?.masterKey?.finalKey || raw?.masterKey?.lockedKey || empty.masterKey.finalKey).trim()
      },
      sourceLibrary: {
        sheetSources: normalizeLinks(raw?.sourceLibrary?.sheetSources),
        harmonySources: normalizeLinks(raw?.sourceLibrary?.harmonySources),
        audioReferences: normalizeLinks(raw?.sourceLibrary?.audioReferences),
        additionalSources: normalizeLinks(raw?.sourceLibrary?.additionalSources),
        sheetImages
      }
    };
  }

  function defaultProjects() {
    return [
      createDefaultProject({
        id: "cant-help-falling-in-love",
        title: "Can't Help Falling in Love",
        status: "Active",
        progress: 60,
        deadline: "2026-04-20",
        category: "Cover",
        shortDescription: "A warm flute-and-piano performance film with late-night apartment intimacy and a soft chamber lift.",
        thumbnail: DEFAULT_THUMBNAIL,
        gallery: [
          DEFAULT_THUMBNAIL,
          createPlaceholderImage("Lamp Glow", "gold", "Gallery"),
          createPlaceholderImage("Piano Detail", "gold", "Gallery")
        ],
        music: {
          arrangementNotes: "Start with upright piano alone, then let the flute arrive gently. Save the full string bloom for the final chorus.",
          instrumentation: "Lead flute, upright piano, brushed drums, chamber strings quartet, warm upright bass.",
          recordingNotes: "Keep the flute intimate and airy. Let the piano stay woody and close, with a soft room around the strings.",
          musicTasks: [
            "Lock the final string voicings for the last chorus.",
            "Print clean stems for piano, flute, strings, and percussion.",
            "Refine the room-vocal texture in the outro."
          ]
        },
        visual: {
          concept: "A candle-warm apartment performance that feels private, lived-in, and emotionally close.",
          location: "Wood apartment studio with an upright piano, amber practicals, and one soft window edge.",
          wardrobe: "Ivory shirt, cocoa knit layer, dark tailored trousers, minimal accessories.",
          lighting: "Warm lamp pools, one soft moon-edge from the window, and enough shadow to keep the frame cinematic.",
          shotDirection: "Slow dolly movement, patient close framing, hands and breath before wide coverage.",
          visualTasks: [
            "Finalize lamp placement around the piano corner.",
            "Choose one hero frame for poster and thumbnail use.",
            "Lock wardrobe fabric textures before the shoot."
          ]
        },
        inspiration: {
          coreMood: "Warm, intimate, amber, romantic, cinematic, quietly important.",
          referenceNotes: "The room should feel like a love letter instead of a set. Brown wood, lamp glow, and small gestures should carry most of the emotion."
        },
        references: {
          links: [
            { label: "Warm piano interior references", url: "https://www.pexels.com/search/piano%20interior/" },
            { label: "Cinematic warm lighting mood board", url: "https://www.pinterest.com/search/pins/?q=warm%20cinematic%20music%20video%20lighting" }
          ]
        },
      youtubeReferences: [
        "https://www.youtube.com/watch?v=Ay6O7E4bKj0",
        "https://www.youtube.com/watch?v=IAW6VgSLbfs",
        "https://www.youtube.com/watch?v=j1XG7S-A8CI"
      ],
      notes: "",
      production: {
        audio: {
          scoreOrder: ["Flute", "Piano RH", "Piano LH", "Voice"],
          supportsMidiInput: true,
          supportsXmlImport: true,
          sheetReferences: [
            { label: "Main lead sheet", url: "https://musescore.com/" }
          ],
          workflowNotes: "Keep the writing flexible: play, listen back, rebalance harmony, then refine articulations before locking notation.",
          iterationLoop: "Work, listen, adjust, edit, and refine in short passes until the emotional shape feels honest.",
          manualNotes: "Primary setup: flute lead first, then two piano staves, then the voice staff anchored at the bottom."
        },
        image: {
          workflowNotes: "Collect only the frames that support the late-night apartment story and final thumbnail direction.",
          referenceFrames: [
            { label: "Hero frame reference", url: "https://www.pexels.com/search/piano%20interior/" }
          ],
          deliveryNotes: "Thumbnail and project cover should stay warm, cinematic, and readable in Milanote."
        }
      },
      todos: [
        { text: "Approve final key before flute retake", urgency: "urgent" },
        { text: "Collect final string stems for master export", urgency: "soon" },
        { text: "Prepare cover artwork shortlist", urgency: "later", completed: true }
      ]
      }),
      createDefaultProject({
        id: "time-to-say-goodbye",
        title: "Time to Say Goodbye",
        status: "In Progress",
        progress: 45,
        deadline: "2026-05-10",
        category: "Classical Crossover",
        shortDescription: "A wider orchestral crossover arrangement that still needs a cleaner rise through the bridge.",
        thumbnail: createPlaceholderImage("Time to Say Goodbye", "jade", "Project"),
        gallery: [
          createPlaceholderImage("Hall Mood", "jade", "Gallery"),
          createPlaceholderImage("Stage Light", "jade", "Gallery")
        ],
        music: {
          arrangementNotes: "Open the bridge wider than the verse and let the rise feel inevitable instead of immediate.",
          instrumentation: "Flute lead, grand piano, legato strings, low brass support, and restrained choir pad.",
          recordingNotes: "Keep the low brass supportive and give the flute enough air above the orchestra.",
          musicTasks: [
            "Rewrite the bridge voicing shape.",
            "Rebalance the high flute line against the string bed."
          ]
        },
        visual: {
          concept: "Elegant room-scale performance with more air and distance than the intimate songs.",
          location: "Dark recital hall or clean scoring room.",
          wardrobe: "Formal black with one softened texture.",
          lighting: "Cool edge with a warmer pool on piano and performer.",
          shotDirection: "Slower reveals and wider frames to preserve scale.",
          visualTasks: [
            "Choose between recital hall and scoring room.",
            "Test wider camera spacing before shot list lock."
          ]
        },
        inspiration: {
          coreMood: "Expansive, elegant, restrained grandeur.",
          referenceNotes: "Think refined crossover performance, not operatic spectacle."
        },
        references: {
          links: [
            { label: "Concert hall references", url: "https://www.pexels.com/search/concert%20hall/" }
          ]
        },
        youtubeReferences: [
          "https://www.youtube.com/watch?v=j1XG7S-A8CI"
        ],
        notes: "",
        todos: [
          { text: "Choose between recital hall and scoring room", urgency: "urgent" },
          { text: "Collect one final harmony reference", urgency: "soon" }
        ]
      }),
      createDefaultProject({
        id: "hello-viet-nam",
        title: "Hello Việt Nam",
        status: "Draft",
        progress: 15,
        deadline: "2026-06-15",
        category: "Original",
        shortDescription: "An early concept piece shaped around memory, belonging, and a softer contemporary-classical voice.",
        thumbnail: createPlaceholderImage("Hello Việt Nam", "sky", "Project"),
        gallery: [
          createPlaceholderImage("Morning Light", "sky", "Gallery")
        ],
        music: {
          arrangementNotes: "Keep the melodic language open and singable while the emotional center is still forming.",
          instrumentation: "Flute, piano, gentle strings, subtle percussion, optional ambient field texture.",
          recordingNotes: "The mix should feel airy and nostalgic, not polished and oversized.",
          musicTasks: [
            "Collect three melodic references.",
            "Build the first moodboard before writing verse two."
          ]
        },
        visual: {
          concept: "Poetic memory images instead of literal travel imagery.",
          location: "Soft natural-light apartment or quiet heritage interior.",
          wardrobe: "Simple neutral tailoring with one traditional accent.",
          lighting: "Morning softness with pale gold highlights.",
          shotDirection: "Gentle motion with attention on meaningful objects.",
          visualTasks: [
            "Define one emotional point of view.",
            "Collect the first set of heritage textures."
          ]
        },
        inspiration: {
          coreMood: "Poetic, personal, nostalgic, dignified.",
          referenceNotes: "The references should feel lived-in and sincere, never touristic."
        },
        references: {
          links: [
            { label: "Quiet warm interior references", url: "https://www.pexels.com/search/warm%20interior/" }
          ]
        },
        youtubeReferences: [],
        notes: "",
        todos: [
          { text: "Build first source library set", urgency: "soon" },
          { text: "Lock one memory-led visual concept", urgency: "later" }
        ]
      }),
      createDefaultProject({
        id: "la-la-land-theme",
        title: "La La Land Theme",
        status: "In Progress",
        progress: 30,
        deadline: "2026-05-05",
        category: "Cover",
        shortDescription: "A romantic arrangement still balancing jazz nostalgia with enough motion and lift.",
        thumbnail: createPlaceholderImage("La La Land Theme", "jade", "Project"),
        gallery: [
          createPlaceholderImage("Night Reflections", "jade", "Gallery"),
          createPlaceholderImage("City Practicals", "jade", "Gallery")
        ],
        music: {
          arrangementNotes: "Let the counter-melody answer the theme instead of competing with it.",
          instrumentation: "Piano, flute, brushed rhythm section, lush strings, narrow brass color.",
          recordingNotes: "Protect the piano articulation while letting the ensemble wrap around it.",
          musicTasks: [
            "Finish the counter-melody line.",
            "Approve the final chord voicings."
          ]
        },
        visual: {
          concept: "Urban romance without direct film imitation.",
          location: "Minimal studio with reflections and practical bulbs.",
          wardrobe: "Tailored dark look with one champagne-toned accent.",
          lighting: "Soft practical glow with one cool reflective source.",
          shotDirection: "Elegant wides and slow pivots.",
          visualTasks: [
            "Choose a single night interior anchor.",
            "Collect practical light references."
          ]
        },
        inspiration: {
          coreMood: "Reflective, nocturnal, romantic, modern-classic.",
          referenceNotes: "Reference jazz romance and city-night calm more than direct homage."
        },
        references: {
          links: [
            { label: "Night interior references", url: "https://www.pexels.com/search/night%20interior/" }
          ]
        },
        youtubeReferences: [
          "https://www.youtube.com/watch?v=IAW6VgSLbfs"
        ],
        notes: "",
        todos: [
          { text: "Finish counter-melody voicing", urgency: "urgent" },
          { text: "Review practical-light references", urgency: "later" }
        ]
      }),
      createDefaultProject({
        id: "my-heart-will-go-on",
        title: "My Heart Will Go On",
        status: "Released",
        progress: 100,
        deadline: "",
        category: "Cover",
        shortDescription: "A completed release used as a benchmark for emotional polish and finished delivery.",
        thumbnail: createPlaceholderImage("My Heart Will Go On", "violet", "Project"),
        gallery: [
          createPlaceholderImage("Release Frame", "violet", "Gallery")
        ],
        music: {
          arrangementNotes: "Future live versions should stay aligned with the released arrangement shape.",
          instrumentation: "Flute lead, piano, strings, and cinematic support textures.",
          recordingNotes: "Reference the approved master and release stems for any future edits.",
          musicTasks: [
            "Prepare any live adaptation from the release session."
          ]
        },
        visual: {
          concept: "Release visual language already approved.",
          location: "Archive",
          wardrobe: "Approved",
          lighting: "Approved",
          shotDirection: "Use the released visual system as the benchmark.",
          visualTasks: [
            "Archive all release selects."
          ]
        },
        inspiration: {
          coreMood: "Epic, romantic, archival.",
          referenceNotes: "This project now functions as a benchmark rather than an active exploration."
        },
        references: {
          links: [
            { label: "Release archive", url: "https://www.youtube.com/" }
          ]
        },
        youtubeReferences: [],
        notes: "",
        todos: [
          { text: "Archive release stills and masters", urgency: "later", completed: true }
        ]
      })
    ];
  }

  function normalizeLinks(links) {
    if (!Array.isArray(links)) return [];
    return links
      .map((link) => {
        if (typeof link === "string") {
          const trimmed = link.trim();
          return trimmed ? { label: trimmed, url: trimmed } : null;
        }
        if (!link || !link.url) return null;
        return {
          label: String(link.label || link.url).trim(),
          url: String(link.url).trim()
        };
      })
      .filter((link) => link && link.url);
  }

  function normalizeProject(raw) {
    const fallbackId = slugify(raw?.id || raw?.title || "");
    const thumbnail = raw?.thumbnail || "";
    const gallery = Array.isArray(raw?.gallery) ? raw.gallery.filter(Boolean) : [];
    const project = {
      id: fallbackId,
      title: String(raw?.title || "").trim(),
      author: String(raw?.author || "The Flutiano").trim() || "The Flutiano",
      status: normalizeStatus(raw?.status),
      progress: Math.max(0, Math.min(100, Number(raw?.progress ?? 0) || 0)),
      deadline: String(raw?.deadline || "").trim(),
      category: String(raw?.category || "Cover").trim() || "Cover",
      shortDescription: String(raw?.shortDescription || "").trim(),
      thumbnail,
      gallery,
      music: {
        arrangementNotes: String(raw?.music?.arrangementNotes || "").trim(),
        instrumentation: String(raw?.music?.instrumentation || "").trim(),
        recordingNotes: String(raw?.music?.recordingNotes || "").trim(),
        selectedInstruments: normalizeSelectedInstruments(raw?.music),
        musicTasks: Array.isArray(raw?.music?.musicTasks)
          ? raw.music.musicTasks.map((item) => String(item).trim()).filter(Boolean)
          : []
      },
      visual: {
        concept: String(raw?.visual?.concept || "").trim(),
        location: String(raw?.visual?.location || "").trim(),
        wardrobe: String(raw?.visual?.wardrobe || "").trim(),
        lighting: String(raw?.visual?.lighting || "").trim(),
        shotDirection: String(raw?.visual?.shotDirection || "").trim(),
        visualTasks: Array.isArray(raw?.visual?.visualTasks)
          ? raw.visual.visualTasks.map((item) => String(item).trim()).filter(Boolean)
          : []
      },
      inspiration: {
        coreMood: String(raw?.inspiration?.coreMood || "").trim(),
        referenceNotes: String(raw?.inspiration?.referenceNotes || "").trim()
      },
      references: {
        links: normalizeLinks(raw?.references?.links)
      },
      youtubeReferences: Array.isArray(raw?.youtubeReferences)
        ? raw.youtubeReferences.map((item) => String(item).trim()).filter(Boolean)
        : [],
      notes: String(raw?.notes || "").trim(),
      production: normalizeProduction(raw?.production),
      songWorkflow: normalizeSongWorkflow(raw?.songWorkflow),
      todos: normalizeTodos(raw?.todos)
    };

    if (project.notes === LEGACY_EMOTIONAL_NOTE) {
      project.notes = "";
    }

    if (project.id === "cant-help-falling-in-love") {
      if (!project.songWorkflow.masterKey.originalKey) {
        project.songWorkflow.masterKey.originalKey = "E major";
      }
      if (!project.songWorkflow.masterKey.finalKey) {
        project.songWorkflow.masterKey.finalKey = "F major";
      }
      if (!project.songWorkflow.masterKey.priorityKeys.length) {
        project.songWorkflow.masterKey.priorityKeys = DEFAULT_PRIORITY_KEYS.slice();
      }
      if (!project.songWorkflow.sourceLibrary.sheetSources.length) {
        project.songWorkflow.sourceLibrary.sheetSources = normalizeLinks([
          { label: "MuseScore Lead Sheet", url: "https://musescore.com/" }
        ]);
      }
      if (!project.songWorkflow.sourceLibrary.harmonySources.length) {
        project.songWorkflow.sourceLibrary.harmonySources = normalizeLinks([
          { label: "Tabs & Chords Reference", url: "https://tabs.ultimate-guitar.com/" }
        ]);
      }
      if (!project.songWorkflow.sourceLibrary.audioReferences.length) {
        project.songWorkflow.sourceLibrary.audioReferences = normalizeLinks([
          { label: "YouTube Performance Reference", url: "https://www.youtube.com/watch?v=Ay6O7E4bKj0" }
        ]);
      }
      if (!project.songWorkflow.sourceLibrary.additionalSources.length) {
        project.songWorkflow.sourceLibrary.additionalSources = normalizeLinks([
          { label: "Lyric Reference", url: "https://en.wikipedia.org/wiki/Can%27t_Help_Falling_in_Love" }
        ]);
      }
    }

    return project;
  }

  let cache = null;

  function loadProjects() {
    if (cache) return cache;
    try {
      const raw = window.localStorage.getItem(STORAGE_KEY);
      if (!raw) {
        cache = defaultProjects();
        return cache;
      }
      const parsed = JSON.parse(raw);
      cache = Array.isArray(parsed) && parsed.length
        ? parsed.map(normalizeProject)
        : defaultProjects();
    } catch (error) {
      cache = defaultProjects();
    }
    return cache;
  }

  function saveProjects(projects) {
    cache = projects.map(normalizeProject);
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(cache));
    } catch (error) {
      // Ignore storage errors and continue with in-memory state.
    }
    try {
      window.dispatchEvent(new CustomEvent(TODO_UPDATE_EVENT, { detail: { projects: getProjects() } }));
    } catch (error) {
      // Ignore event dispatch errors.
    }
    return cache;
  }

  function getProjects() {
    return loadProjects().map((project) => normalizeProject(project));
  }

  function getProject(id) {
    return getProjects().find((project) => project.id === id) || null;
  }

  function getDefaultProject() {
    return getProjects()[0] || null;
  }

  function upsertProject(project) {
    const normalized = normalizeProject(project);
    const projects = getProjects();
    const index = projects.findIndex((item) => item.id === normalized.id);
    if (index >= 0) {
      projects[index] = normalized;
    } else {
      projects.unshift(normalized);
    }
    saveProjects(projects);
    return normalized;
  }

  function createProjectId(title) {
    const base = slugify(title);
    const projects = getProjects();
    if (!projects.some((project) => project.id === base)) return base;
    let count = 2;
    while (projects.some((project) => project.id === `${base}-${count}`)) {
      count += 1;
    }
    return `${base}-${count}`;
  }

  function createEmptyProject(title) {
    const id = createProjectId(title || "untitled");
    return normalizeProject({
      id,
      title: title || "",
      author: "The Flutiano",
      status: "Draft",
      progress: 0,
      deadline: "",
      category: "Cover",
      shortDescription: "",
      thumbnail: "",
      gallery: [],
      music: {
        arrangementNotes: "",
        instrumentation: "",
        recordingNotes: "",
        selectedInstruments: [],
        musicTasks: []
      },
      visual: {
        concept: "",
        location: "",
        wardrobe: "",
        lighting: "",
        shotDirection: "",
        visualTasks: []
      },
      inspiration: {
        coreMood: "",
        referenceNotes: ""
      },
      references: {
        links: []
      },
      youtubeReferences: [],
      notes: "",
      production: createEmptyProduction(),
      songWorkflow: createEmptySongWorkflow(),
      todos: []
    });
  }

  function getTodoGroups(completed) {
    return getProjects()
      .map((project) => ({
        project,
        todos: project.todos.filter((todo) => Boolean(todo.completed) === Boolean(completed))
      }))
      .filter((group) => group.todos.length)
      .sort((left, right) => {
        const leftDeadline = left.project.deadline || "9999-12-31";
        const rightDeadline = right.project.deadline || "9999-12-31";
        if (leftDeadline !== rightDeadline) return leftDeadline.localeCompare(rightDeadline);
        return left.project.title.localeCompare(right.project.title);
      });
  }

  function addProjectTodo(projectId, input) {
    const project = getProject(projectId);
    if (!project) return null;
    const todo = createTodo(input);
    if (!todo.text) return project;
    return upsertProject({
      ...project,
      todos: normalizeTodos([todo, ...project.todos])
    });
  }

  function toggleProjectTodo(projectId, todoId, completed) {
    const project = getProject(projectId);
    if (!project) return null;
    return upsertProject({
      ...project,
      todos: project.todos.map((todo) => (
        todo.id !== todoId
          ? todo
          : createTodo({
            ...todo,
            completed,
            completedAt: completed ? new Date().toISOString() : ""
          })
      ))
    });
  }

  function getSongWorkflowState(project) {
    const workflow = normalizeSongWorkflow(project?.songWorkflow);
    const masterKey = workflow.masterKey;
    const library = workflow.sourceLibrary;

    const hasMasterKeyDraft = Boolean(
      masterKey.originalKey ||
      masterKey.priorityKeys.length
    );

    let masterKeyStatus = "empty";
    if (masterKey.finalKey) {
      masterKeyStatus = "done";
    } else if (hasMasterKeyDraft) {
      masterKeyStatus = "in-progress";
    }

    const sheetCount = library.sheetSources.length;
    const harmonyCount = library.harmonySources.length;
    const audioCount = library.audioReferences.length;
    const additionalCount = library.additionalSources.length;
    const hasLibraryDraft = Boolean(
      sheetCount ||
      harmonyCount ||
      audioCount ||
      additionalCount
    );

    let sourceLibraryStatus = "empty";
    if (sheetCount && harmonyCount && audioCount && additionalCount) {
      sourceLibraryStatus = "done";
    } else if (hasLibraryDraft) {
      sourceLibraryStatus = "in-progress";
    }

    return {
      masterKey: {
        status: masterKeyStatus,
        originalKey: masterKey.originalKey,
        priorityKeys: masterKey.priorityKeys,
        finalKey: masterKey.finalKey
      },
      sourceLibrary: {
        status: sourceLibraryStatus,
        sheetCount,
        harmonyCount,
        audioCount,
        additionalCount,
        sheetSources: library.sheetSources,
        harmonySources: library.harmonySources,
        audioReferences: library.audioReferences,
        additionalSources: library.additionalSources
      }
    };
  }

  function getSourceLibraryEntries(project) {
    const workflow = normalizeSongWorkflow(project?.songWorkflow);
    const images = workflow.sourceLibrary.sheetImages || {};

    return {
      sheet: workflow.sourceLibrary.sheetSources.map((item) => ({ ...item, type: "link" })).concat(
        ["musescore", "youtube", "website"].flatMap((source) =>
          (images[source] || []).map((entry) => ({
            label: String(entry.label || "Sheet image").trim() || "Sheet image",
            url: String(entry.url || "").trim(),
            images: Array.isArray(entry.images) ? entry.images.slice() : [],
            source,
            type: "image"
          }))
        )
      ),
      harmony: workflow.sourceLibrary.harmonySources.slice(),
      audio: workflow.sourceLibrary.audioReferences.slice(),
      additional: workflow.sourceLibrary.additionalSources.slice()
    };
  }

  function getKeyShift(originalKey, finalKey) {
    const fromRoot = String(originalKey || "").split(" ")[0];
    const toRoot = String(finalKey || "").split(" ")[0];
    if (!(fromRoot in KEY_ROOT_INDEX) || !(toRoot in KEY_ROOT_INDEX)) return null;

    let diff = KEY_ROOT_INDEX[toRoot] - KEY_ROOT_INDEX[fromRoot];
    if (diff > 6) diff -= 12;
    if (diff < -6) diff += 12;
    return diff;
  }

  function getKeyShiftLabel(originalKey, finalKey) {
    const diff = getKeyShift(originalKey, finalKey);
    if (diff === null) return "—";
    if (diff === 0) return "0";
    return diff > 0 ? `+${diff}` : `${diff}`;
  }

  function getKeyShiftDescription(originalKey, finalKey) {
    const diff = getKeyShift(originalKey, finalKey);
    if (diff === null) return "No shift";
    if (diff === 0) return "0 semitones";
    return `${diff > 0 ? `+${diff}` : diff} semitones`;
  }

  function getKeyTheory(keyName) {
    return KEY_THEORY_LIBRARY[String(keyName || "").trim()] || null;
  }

  function formatDate(value, compact) {
    if (!value) return "Chưa có deadline";
    const date = new Date(`${value}T00:00:00`);
    if (Number.isNaN(date.getTime())) return value;
    const day = String(date.getDate()).padStart(2, "0");
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const year = date.getFullYear();
    return `${day}/${month}/${year}`;
  }

  function getTone(project) {
    const status = (project?.status || "").toLowerCase();
    if (status === "released") return "violet";
    if (status === "draft") return "sky";
    if (status === "in progress") return "jade";
    return "gold";
  }

  function getThumbnail(project) {
    return project?.thumbnail || createPlaceholderImage(project?.title || "Untitled", getTone(project), "Project");
  }

  function getGallery(project) {
    const images = Array.isArray(project?.gallery) ? project.gallery.filter(Boolean) : [];
    if (images.length) return images;
    return [getThumbnail(project)];
  }

  function extractYouTubeId(input) {
    try {
      const url = new URL(input);
      const host = url.hostname.replace(/^www\./, "");
      if (host === "youtu.be") {
        return url.pathname.slice(1) || null;
      }
      if (host === "youtube.com" || host === "m.youtube.com") {
        if (url.pathname === "/watch") {
          return url.searchParams.get("v");
        }
        if (url.pathname.startsWith("/embed/") || url.pathname.startsWith("/shorts/")) {
          return url.pathname.split("/")[2] || null;
        }
      }
    } catch (error) {
      return null;
    }
    return null;
  }

  function getYouTubeThumbnail(url) {
    const videoId = extractYouTubeId(url);
    return videoId ? `https://img.youtube.com/vi/${videoId}/hqdefault.jpg` : "";
  }

  function getYouTubeUrl(url) {
    const videoId = extractYouTubeId(url);
    return videoId ? `https://www.youtube.com/watch?v=${videoId}` : url;
  }

  function readFileAsDataUrl(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  function readFilesAsDataUrls(fileList) {
    return Promise.all(Array.from(fileList || []).map(readFileAsDataUrl));
  }

  function splitMultiline(value) {
    return String(value || "")
      .split("\n")
      .map((item) => item.trim())
      .filter(Boolean);
  }

  function joinMultiline(values) {
    return (values || []).join("\n");
  }

  function parseLinkLines(value) {
    return splitMultiline(value).map((line) => {
      const parts = line.split("|").map((part) => part.trim()).filter(Boolean);
      if (parts.length > 1) {
        return { label: parts[0], url: parts.slice(1).join(" | ") };
      }
      return { label: line, url: line };
    }).filter((item) => item.url);
  }

  function linksToMultiline(links) {
    return normalizeLinks(links)
      .map((link) => `${link.label} | ${link.url}`)
      .join("\n");
  }

  function getDetailUrl(id) {
    return `project-detail.html?project=${encodeURIComponent(id)}`;
  }

  function getMusicUrl(id) {
    return `project-music.html?project=${encodeURIComponent(id)}`;
  }

  function getVisualUrl(id) {
    return `project-visual.html?project=${encodeURIComponent(id)}`;
  }

  function getEditUrl(id, anchor) {
    const href = `edit-project.html?project=${encodeURIComponent(id)}`;
    return anchor ? `${href}#${encodeURIComponent(anchor)}` : href;
  }

  function getStepOneUrl(id) {
    return `project-step-1.html?project=${encodeURIComponent(id)}`;
  }

  const INSTRUMENT_LIBRARY = [
    { id: "Piano",           label: "Piano",          img: "assets/instruments/piano.png" },
    { id: "Voice",           label: "Voice",           img: "assets/instruments/voice.png" },
    { id: "Drums",           label: "Drums",           img: "assets/instruments/drums.png" },
    { id: "Western concert flute",   label: "Western Flute",   img: "assets/instruments/western-flute.png" },
    { id: "Vietnamese bamboo flute",    label: "Bamboo Flute",    img: "assets/instruments/bamboo-flute.png" },
    { id: "Chinese dizi",            label: "Dizi",            img: "assets/instruments/dizi.png" },
    { id: "Vietnamese zither",       label: "Đàn Tranh",       img: "assets/instruments/dan-tranh.png" },
    { id: "Chinese zither",         label: "Guzheng",         img: "assets/instruments/guzheng.png" }
  ];

  window.FlutianoProjectStore = {
    STORAGE_KEY,
    TODO_UPDATE_EVENT,
    createPlaceholderImage,
    createTodo,
    createEmptyProject,
    createEmptySongWorkflow,
    createProjectId,
    defaultProjects,
    INSTRUMENT_OPTIONS,
    INSTRUMENT_LIBRARY,
    SOURCE_LIBRARY_GROUPS,
    KEY_OPTIONS,
    KEY_THEORY_LIBRARY,
    normalizeTodoUrgency,
    getProjects,
    getProject,
    getDefaultProject,
    getTodoGroups,
    upsertProject,
    saveProjects,
    normalizeProject,
    slugify,
    formatDate,
    getTone,
    getThumbnail,
    getGallery,
    getDetailUrl,
    getMusicUrl,
    getVisualUrl,
    getEditUrl,
    getStepOneUrl,
    getSongWorkflowState,
    getSourceLibraryEntries,
    getKeyShift,
    getKeyShiftLabel,
    getKeyShiftDescription,
    getKeyTheory,
    extractYouTubeId,
    getYouTubeThumbnail,
    getYouTubeUrl,
    addProjectTodo,
    toggleProjectTodo,
    readFileAsDataUrl,
    readFilesAsDataUrls,
    splitMultiline,
    joinMultiline,
    parseLinkLines,
    linksToMultiline
  };
})();

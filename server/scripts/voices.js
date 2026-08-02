const fs = require('fs');
const path = require('path');
const axios = require('axios');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const API_URL = 'https://api.mistral.ai/v1';
const API_KEY = process.env.MISTRAL_API_KEY;

if (!API_KEY) {
  console.error('MISTRAL_API_KEY manquante dans server/.env');
  process.exit(1);
}

const headers = { Authorization: `Bearer ${API_KEY}` };

async function list() {
  const { data } = await axios.get(`${API_URL}/audio/voices`, { headers, timeout: 30000 });
  const voices = data?.data || data?.voices || [];
  if (voices.length === 0) {
    console.log('Aucune voix enregistrée.');
  }
  for (const v of voices) {
    console.log(`id: ${v.id}\n  name: ${v.name}\n  languages: ${(v.languages || []).join(', ')}\n`);
  }
}

async function create(name, audioFile, languages, gender) {
  if (!name || !audioFile) {
    console.error('Usage: node scripts/voices.js create <nom> <fichierAudio> [langues(ex: fr,en)] [genre]');
    process.exit(1);
  }
  if (!fs.existsSync(audioFile)) {
    console.error(`Fichier introuvable: ${audioFile}`);
    process.exit(1);
  }
  const ext = path.extname(audioFile).replace('.', '');
  const sampleAudio = fs.readFileSync(audioFile).toString('base64');

  const body = {
    name,
    sample_audio: sampleAudio,
    sample_filename: path.basename(audioFile),
  };
  if (languages) body.languages = languages.split(',').map((l) => l.trim());
  if (gender) body.gender = gender;

  try {
    const { data } = await axios.post(`${API_URL}/audio/voices`, body, { headers, timeout: 120000 });
    console.log('Voix créée:');
    console.log(`id: ${data.id}`);
    console.log(`name: ${data.name}`);
    if (data.languages) console.log(`languages: ${data.languages.join(', ')}`);
    console.log('\nÀ mettre dans server/.env:');
    console.log(`MISTRAL_VOICE_ID=${data.id}`);
  } catch (e) {
    console.error('Erreur création voix:', e.response?.data?.error?.message || e.message);
    process.exit(1);
  }
}

const [cmd, ...args] = process.argv.slice(2);
switch (cmd) {
  case 'list':
    list().catch((e) => console.error('Erreur:', e.response?.data?.error?.message || e.message));
    break;
  case 'create':
    create(args[0], args[1], args[2], args[3]).catch((e) => console.error('Erreur:', e.message));
    break;
  default:
    console.log('Usage:');
    console.log('  node scripts/voices.js list');
    console.log('  node scripts/voices.js create <nom> <fichierAudio> [langues] [genre]');
}

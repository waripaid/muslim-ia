const axios = require('axios');
const logger = require('../utils/logger');

const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_API_KEY = process.env.GROQ_API_KEY;

// Taille max d'une image base64 (≈ 10 Mo) — protège la mémoire.
const MAX_IMAGE_BASE64 = 14 * 1024 * 1024;

async function analyzeImage(imageBase64, prompt = 'Décris cette image en détail.') {
  if (typeof imageBase64 !== 'string' || imageBase64.length === 0) {
    return { success: false, error: 'Aucune image reçue' };
  }
  if (imageBase64.length > MAX_IMAGE_BASE64) {
    return { success: false, error: 'Image trop volumineuse (maximum 10 Mo)' };
  }
  try {
    const response = await axios.post(GROQ_API_URL, {
      model: 'qwen/qwen3.6-27b',
      messages: [{
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${imageBase64}` } },
        ],
      }],
      max_completion_tokens: 1024,
      temperature: 0.7,
    }, {
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${GROQ_API_KEY}` },
      timeout: 30000,
    });

    return {
      success: true,
      text: response.data.choices[0].message.content,
    };
  } catch (error) {
    logger.error('Vision', 'Erreur analyse image', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Analyse une image avec un contexte islamique
 */
async function analyzeIslamicImage(imageBase64, context = '') {
  const defaultPrompt = `Analyse cette image. Si c'est un verset du Coran :
- Identifie la sourate et le numéro du verset
- Donne le texte en arabe et la traduction
- Explique le contexte et les leçons à en tirer

Si c'est un aliment ou un produit :
- Dis s'il est halal ou haram
- Explique pourquoi
- Mentionne les ingrédients ou certifications si visibles

Si c'est autre chose, décris simplement ce que tu vois.`;

  return await analyzeImage(imageBase64, context || defaultPrompt);
}

module.exports = { analyzeImage, analyzeIslamicImage };

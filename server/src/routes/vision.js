const express = require('express');
const router = express.Router();
const { analyzeIslamicImage } = require('../services/vision');

/**
 * POST /api/vision/analyze
 * Analyse une image via Groq Vision
 */
router.post('/analyze', async (req, res, next) => {
  try {
    const { image, context } = req.body;
    if (!image) return res.status(400).json({ error: 'image (base64) requise' });

    const result = await analyzeIslamicImage(image, context);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

module.exports = router;

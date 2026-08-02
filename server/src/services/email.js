require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });

const axios = require('axios');
const logger = require('../utils/logger');

const APP_NAME = 'Muslim IA';
const APP_TAGLINE = 'Apprendre le Coran et l\'arabe avec l\'IA';

function isBrevoConfigured() {
  return !!(process.env.BREVO_API_KEY && process.env.BREVO_SENDER_EMAIL);
}

function getLogoUrl() {
  return process.env.PUBLIC_LOGO_URL || '';
}

/**
 * Construit le template HTML de l'email de vérification (avec le logo de l'app).
 */
function buildVerificationHtml({ displayName, email, link }) {
  const logo = getLogoUrl();
  const logoHtml = logo
    ? `<img src="${logo}" alt="${APP_NAME} logo" width="110" height="110" style="display:block;width:110px;height:110px;max-width:110px;border-radius:22px;border:0;outline:none;text-decoration:none;" />`
    : `<div style="width:110px;height:110px;border-radius:22px;background:#C5A028;display:flex;align-items:center;justify-content:center;color:#0F1B4C;font-size:44px;font-weight:900;line-height:110px;">${APP_NAME.charAt(0)}</div>`;

  const firstName = (displayName || email || '').split(' ')[0];

  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Vérifiez votre adresse email</title>
</head>
<body style="margin:0;padding:0;background:#F4F6FB;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#F4F6FB;">
    <tr>
      <td align="center" style="padding:32px 16px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:100%;background:#FFFFFF;border-radius:20px;overflow:hidden;border:1px solid #E8ECF5;">
          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#0A0E2E 0%,#0F1B4C 50%,#1E3A8A 100%);padding:36px 32px;text-align:center;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center" style="padding-bottom:16px;">
                    ${logoHtml}
                  </td>
                </tr>
                <tr>
                  <td align="center">
                    <span style="font-family:Georgia,'Times New Roman',serif;color:#FFFFFF;font-size:30px;font-weight:bold;letter-spacing:0.5px;">${APP_NAME}</span>
                  </td>
                </tr>
                <tr>
                  <td align="center">
                    <span style="font-family:Arial,Helvetica,sans-serif;color:#A8B3D9;font-size:13px;">${APP_TAGLINE}</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <h1 style="font-family:Arial,Helvetica,sans-serif;color:#0F1B4C;font-size:22px;margin:0 0 12px 0;text-align:center;">Vérifiez votre adresse email</h1>
              <p style="font-family:Arial,Helvetica,sans-serif;color:#3D4B6A;font-size:15px;line-height:24px;margin:0 0 20px 0;text-align:center;">
                Bonjour ${firstName},<br/>
                Merci d'avoir créé votre compte ${APP_NAME}. Pour confirmer votre adresse <strong>${email}</strong>, cliquez sur le bouton ci-dessous :
              </p>
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center" style="padding:8px 0 24px 0;">
                    <a href="${link}" target="_blank" style="font-family:Arial,Helvetica,sans-serif;display:inline-block;background:#C5A028;color:#0F1B4C;font-size:16px;font-weight:bold;text-decoration:none;padding:14px 36px;border-radius:12px;">
                      Vérifier mon email
                    </a>
                  </td>
                </tr>
              </table>
              <p style="font-family:Arial,Helvetica,sans-serif;color:#7A86A3;font-size:12px;line-height:19px;margin:0 0 8px 0;text-align:center;">
                Si le bouton ne fonctionne pas, copiez et collez ce lien dans votre navigateur :<br/>
                <a href="${link}" style="color:#1E3A8A;word-break:break-all;">${link}</a>
              </p>
              <p style="font-family:Arial,Helvetica,sans-serif;color:#7A86A3;font-size:12px;line-height:19px;margin:12px 0 0 0;text-align:center;">
                Ce lien expirera dans 24 heures. Si vous n'avez pas demandé cette vérification, vous pouvez ignorer cet email.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#F4F6FB;padding:20px 32px;text-align:center;border-top:1px solid #E8ECF5;">
              <p style="font-family:Arial,Helvetica,sans-serif;color:#A0A9BE;font-size:11px;margin:0;">
                © ${new Date().getFullYear()} ${APP_NAME} · Cet email a été envoyé automatiquement.<br/>
                Merci d'utiliser ${APP_NAME}.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

/**
 * Envoie un email via l'API Brevo (v3 smtp/email).
 */
async function sendEmail({ to, subject, html, replyTo }) {
  if (!isBrevoConfigured()) {
    logger.warn('Email', 'Brevo non configuré (BREVO_API_KEY / BREVO_SENDER_EMAIL manquants). Email non envoyé.');
    return { sent: false, reason: 'brevo_not_configured' };
  }

  const payload = {
    sender: {
      name: process.env.BREVO_SENDER_NAME || APP_NAME,
      email: process.env.BREVO_SENDER_EMAIL,
    },
    to: [{ email: to }],
    subject,
    htmlContent: html,
  };

  if (replyTo) {
    payload.replyTo = { name: process.env.BREVO_SENDER_NAME || APP_NAME, email: replyTo };
  }

  try {
    const response = await axios.post('https://api.brevo.com/v3/smtp/email', payload, {
      headers: {
        'Content-Type': 'application/json',
        'api-key': process.env.BREVO_API_KEY,
        Accept: 'application/json',
      },
      timeout: 15000,
    });
    logger.success('Email', `Envoyé vers ${to} (Brevo messageId: ${response.data?.messageId || '?'})`);
    return { sent: true, messageId: response.data?.messageId };
  } catch (error) {
    const detail = error.response?.data?.message || error.message;
    logger.error('Email', `Échec envoi Brevo vers ${to}: ${detail}`);
    return { sent: false, reason: detail };
  }
}

/**
 * Envoie l'email de vérification d'adresse.
 */
async function sendVerificationEmail({ to, displayName, link }) {
  const html = buildVerificationHtml({ displayName, email: to, link });
  return sendEmail({
    to,
    subject: `Vérifiez votre adresse email - ${APP_NAME}`,
    html,
    replyTo: process.env.BREVO_SENDER_EMAIL,
  });
}

module.exports = {
  isBrevoConfigured,
  sendVerificationEmail,
  sendEmail,
  buildVerificationHtml,
};

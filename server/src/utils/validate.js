/**
 * Validation simple des entrées (anti-DoS / anti-abus) :
 * bornes les longueurs des chaînes et des tableaux avant tout traitement.
 */

const DEFAULT_MAX = 5000;

/**
 * Valide une chaîne optionnelle ou requise.
 * @returns {{ value?: string, error?: string }}
 */
function str(value, { max = DEFAULT_MAX, name = 'champ', required = false } = {}) {
  if (value === undefined || value === null || value === '') {
    if (required) return { error: `${name} requis` };
    return { value: undefined };
  }
  if (typeof value !== 'string') {
    return { error: `${name} doit être une chaîne de caractères` };
  }
  const v = value.trim();
  if (required && v.length === 0) return { error: `${name} requis` };
  if (v.length > max) {
    return { error: `${name} trop long (maximum ${max} caractères)` };
  }
  return { value: v };
}

/**
 * Valide un tableau optionnel avec un nombre max d'éléments.
 */
function arr(value, { max = 50, name = 'liste', required = false } = {}) {
  if (value === undefined || value === null) {
    if (required) return { error: `${name} requis` };
    return { value: undefined };
  }
  if (!Array.isArray(value)) {
    return { error: `${name} doit être une liste` };
  }
  if (value.length > max) {
    return { error: `${name} trop longue (maximum ${max} éléments)` };
  }
  return { value };
}

module.exports = { str, arr };

/// Validateurs de champs (sécurité) partagés entre les écrans.
library;

/// Domaines d'email bien connus acceptés.
const Set<String> kKnownEmailDomains = {
  'gmail.com', 'googlemail.com',
  'outlook.com', 'outlook.fr', 'hotmail.com', 'hotmail.fr', 'live.com', 'live.fr', 'msn.com',
  'yahoo.com', 'ymail.com', 'gmx.com', 'gmx.fr',
  'icloud.com', 'me.com', 'mac.com',
  'protonmail.com', 'proton.me', 'pm.me',
  'aol.com', 'mail.com', 'zoho.com', 'yandex.com', 'hey.com', 'fastmail.com',
  'orange.fr', 'sfr.fr', 'free.fr', 'laposte.net', 'wanadoo.fr',
};

final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})+$');

/// Retourne un message d'erreur si l'email est invalide, sinon null.
String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Email requis';
  if (!_emailRegex.hasMatch(v)) return 'Email invalide';
  final domain = v.substring(v.indexOf('@') + 1).toLowerCase();
  if (!kKnownEmailDomains.contains(domain)) {
    return 'Domaine non reconnu (gmail.com, outlook.com…)';
  }
  return null;
}

/// Retourne un message d'erreur si le mot de passe est trop faible, sinon null.
String? validatePassword(String value) {
  if (value.isEmpty) return 'Mot de passe requis';
  if (value.length < 8) return 'Minimum 8 caractères';
  if (!value.contains(RegExp(r'[A-Z]'))) return 'Une majuscule requise';
  if (!value.contains(RegExp(r'[a-z]'))) return 'Une minuscule requise';
  if (!value.contains(RegExp(r'[0-9]'))) return 'Un chiffre requis';
  if (!value.contains(RegExp(r'[^A-Za-z0-9]'))) return 'Un caractère spécial requis';
  return null;
}

/// Retourne un message d'erreur si le nom est invalide, sinon null.
String? validateName(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Nom requis';
  if (v.length < 2) return 'Minimum 2 caractères';
  if (v.length > 50) return 'Maximum 50 caractères';
  return null;
}

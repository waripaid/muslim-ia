/// Comptes administrateurs : aucun abonnement requis, fonctionnalités
/// débloquées en illimité (quota, media, thème).
const Set<String> _adminEmails = {'admin@gmail.com'};

bool isAdminEmail(String? email) {
  if (email == null) return false;
  return _adminEmails.contains(email.toLowerCase().trim());
}

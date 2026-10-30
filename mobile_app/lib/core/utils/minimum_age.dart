/// Mirrors `AuthService.MINIMUM_AGE_YEARS` on the backend: an insurance
/// policyholder has to be a legal adult.
const int minimumAgeYears = 18;

int ageOnDate(DateTime dateOfBirth, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var years = today.year - dateOfBirth.year;
  final hasHadBirthday =
      today.month > dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);
  if (!hasHadBirthday) years--;
  return years;
}

bool meetsMinimumAge(DateTime dateOfBirth) =>
    ageOnDate(dateOfBirth) >= minimumAgeYears;

String? validateEmail(String? email) {
  RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
  final isEmailValid = emailRegex.hasMatch(email ?? '');
  if (email!.isEmpty) {
    return 'Please enter a valid email';
  } else if (!isEmailValid) {
    return 'your email should be in this format  "abc@example.com" ';
  }
  return null;
}

String? validatePassword(String? password) {
  if (password == null) {
    return 'Please type a password';
  }
  if (password.length < 6) {
    return 'Your password should at least be 6 characters';
  }
  return null;
}

String? validateNumberId(String? numberId) {
  if (numberId == null) {
    return 'Please type a Number Id';
  }
  if (numberId.length != 11) {
    return 'Your password be 11 characters';
  }
  return null;
}
/*String? validateRating(String? index) {
  if (index == null) {
    return 'Please enter a rating';
  }
  if (index.toString().length > 5) {
    return 'Your rating should below 5 characters';
  }
  return null;
}*/

String? validateConfirmPassword(String? password, String? confirm) {
  if (confirm == null) {
    return 'Please type a password';
  }
  if (confirm.length < 6) {
    return 'Your password should at least be 6 characters';
  }
  if (confirm != password) {
    return "Passwords do not match!";
  }
  return null;
}

String? validateVerification(String? verification) {
  if (verification == null) {
    return 'Please type a code';
  }
  if (verification.length < 6) {
    return 'Your code should at least be 6 characters';
  }
  return null;
}

String? validateName(String? name) {
  //final nameRegex = RegExp(r'^[a-zA-Z\s]{1,50}$');
  if (name == null || name.isEmpty) {
    return 'Name cannot be empty';
  } /*else if ( name.length < 3) {
    return 'Name should be at least 3 characters';
  } else if (!nameRegex.hasMatch(name)) {
    return 'Please enter a valid name';
*/

// Split the name into parts by space
  List<String> nameParts = name.trim().split(' ');

  // Check if there are at least two parts (first name & last name)
  if (nameParts.length < 2) {
    return 'Please enter both your first and last names';
  }

  for (String part in nameParts) {
    // Check if each part has at least two characters
    if (part.length < 2) {
      return 'A name should have 2 characters or more ';
    }
    // Check if each part contains alphabets only
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
      return 'Invalid name format. Please enter alphabets only';
    }
  }

  // If all checks pass
  return null; // = no errors
}

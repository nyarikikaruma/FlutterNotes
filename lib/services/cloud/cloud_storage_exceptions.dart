class CloudStorageException implements Exception {
  CloudStorageException();
}

// C IN CRUD
class CouldNotCreateNotesException extends CloudStorageException {}

// R IN CRUD
class CouldNotReadNotesException extends CloudStorageException {}

// U IN CRUD
class CouldNotUpdateNotesException extends CloudStorageException {}

// D IN CRUD
class CouldNotDeleteNotesException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

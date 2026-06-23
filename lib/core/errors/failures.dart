sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Session expired. Please log in again.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Resource not found.');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

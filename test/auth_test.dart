import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';
void main() {
   group('Mock Authenication', () {
     final provider = MockAuthProvider();
     test('Should not be initialised to begin with', () {
        expect(provider.isInitialized, false);
     });
      test('Cannot logout if not initialized', () {
        provider.logOut();
        throwsA(const TypeMatcher<NotInitializedException>());
      });

    test('Should be able to be initialised', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    
    });
    test('Should be null after initiallization', (){
      expect(provider.currentUser, null);
    
    });
    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
   }, timeout: const Timeout( Duration(seconds: 2)));

   test('Create user should delegate to login function', () async {
     final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'password');
     expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));
     final badPasswordUser = provider.createUser(email: 'someone@bar.com', password: 'foobarbaz');
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
   });

   test('Logged in user should be able to get verified', () {
     provider.sendEmailVerification();
     final user = provider.currentUser;
     expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
   });
    test('Logged in user should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    
    });
}
);
}

class NotInitializedException implements Exception{}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initialize() async {
    await Future.delayed(Duration (seconds: 1));
    _isInitialized = true;

  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(Duration (seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializedException();
    if(email == 'foo@bar.com') throw UserNotFoundAuthException();
    if(password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(id: 'user-id', isEmailVerified: false, email: 'kimani@gmail.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(Duration (seconds: 1));
    _user = null;

  }

  @override
  Future<void> sendEmailVerification() async {
    if(!isInitialized) throw NotInitializedException();
    final user = _user;
    if(user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(id: 'user_id', isEmailVerified: true, email: 'kimani@gmail.com');
    _user = newUser;
  }
}
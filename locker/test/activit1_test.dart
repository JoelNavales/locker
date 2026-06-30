import 'package:flutter_test/flutter_test.dart';
import 'package:locker/models/locker_model.dart';
import 'package:locker/models/task_model.dart';
import 'package:locker/models/user_model.dart';
import 'package:locker/viewmodels/signup_vm.dart';

void main() {
  // ─── Priority ────────────────────────────────────────────────────────────────
  group('Priority.label', () {
    test('high returns HIGH', () => expect(Priority.high.label, 'HIGH'));
    test('medium returns MED', () => expect(Priority.medium.label, 'MED'));
    test('low returns LOW', () => expect(Priority.low.label, 'LOW'));
  });

  // ─── LockerModel ─────────────────────────────────────────────────────────────
  group('LockerModel.fromMap', () {
    test('parses id, subjectName, high priority, and taskCount', () {
      final m = LockerModel.fromMap('id1', {
        'subjectName': 'Math',
        'priority': 'high',
        'taskCount': 3,
      });
      expect(m.id, 'id1');
      expect(m.subjectName, 'Math');
      expect(m.priority, Priority.high);
      expect(m.taskCount, 3);
    });

    test('parses medium priority', () {
      expect(
        LockerModel.fromMap('x', {'priority': 'medium'}).priority,
        Priority.medium,
      );
    });

    test('parses low priority', () {
      expect(
        LockerModel.fromMap('x', {'priority': 'low'}).priority,
        Priority.low,
      );
    });

    test('defaults to Priority.medium for unknown priority', () {
      expect(
        LockerModel.fromMap('x', {'priority': 'unknown'}).priority,
        Priority.medium,
      );
    });

    test('defaults subjectName to empty string when missing', () {
      expect(LockerModel.fromMap('x', {}).subjectName, '');
    });

    test('defaults taskCount to 0 when missing', () {
      expect(LockerModel.fromMap('x', {}).taskCount, 0);
    });
  });

  group('LockerModel.copyWith', () {
    const base = LockerModel(
      id: 'id1',
      subjectName: 'Science',
      priority: Priority.low,
      taskCount: 2,
    );

    test('changes id', () => expect(base.copyWith(id: 'id2').id, 'id2'));
    test('changes subjectName', () {
      expect(base.copyWith(subjectName: 'Physics').subjectName, 'Physics');
    });
    test('changes priority', () {
      expect(base.copyWith(priority: Priority.high).priority, Priority.high);
    });
    test('changes taskCount', () {
      expect(base.copyWith(taskCount: 9).taskCount, 9);
    });
    test('preserves all unchanged fields', () {
      final copy = base.copyWith(taskCount: 9);
      expect(copy.id, 'id1');
      expect(copy.subjectName, 'Science');
      expect(copy.priority, Priority.low);
    });
  });

  // ─── SubTask ─────────────────────────────────────────────────────────────────
  group('SubTask.fromMap', () {
    test('parses title and done', () {
      final s = SubTask.fromMap({'title': 'Read chapter', 'done': true});
      expect(s.title, 'Read chapter');
      expect(s.done, isTrue);
    });

    test('defaults title to empty string when missing', () {
      expect(SubTask.fromMap({}).title, '');
    });

    test('defaults done to false when missing', () {
      expect(SubTask.fromMap({}).done, isFalse);
    });
  });

  group('SubTask.toMap', () {
    test('serializes title and done=true', () {
      expect(
        const SubTask(title: 'Write notes', done: true).toMap(),
        {'title': 'Write notes', 'done': true},
      );
    });

    test('serializes done=false', () {
      expect(
        const SubTask(title: 'Review', done: false).toMap(),
        {'title': 'Review', 'done': false},
      );
    });
  });

  group('SubTask.copyWith', () {
    const sub = SubTask(title: 'Review', done: false);

    test('changes title', () {
      expect(sub.copyWith(title: 'Revised').title, 'Revised');
    });
    test('changes done', () {
      expect(sub.copyWith(done: true).done, isTrue);
    });
    test('preserves unchanged fields', () {
      expect(sub.copyWith(done: true).title, 'Review');
    });
  });

  // ─── TaskModel ───────────────────────────────────────────────────────────────
  group('TaskModel.fromMap', () {
    test('parses id, title, and done', () {
      final t = TaskModel.fromMap('t1', {'title': 'Study', 'done': false});
      expect(t.id, 't1');
      expect(t.title, 'Study');
      expect(t.done, isFalse);
    });

    test('defaults title to empty string when missing', () {
      expect(TaskModel.fromMap('t1', {}).title, '');
    });

    test('defaults done to false when missing', () {
      expect(TaskModel.fromMap('t1', {}).done, isFalse);
    });

    test('converts deadline from epoch milliseconds', () {
      final epoch = DateTime(2025, 6, 1).millisecondsSinceEpoch;
      expect(
        TaskModel.fromMap('t1', {'deadline': epoch}).deadline,
        DateTime.fromMillisecondsSinceEpoch(epoch),
      );
    });

    test('handles null deadline', () {
      expect(TaskModel.fromMap('t1', {}).deadline, isNull);
    });

    test('parses subtasks list', () {
      final t = TaskModel.fromMap('t1', {
        'subtasks': [
          {'title': 'Step 1', 'done': false},
          {'title': 'Step 2', 'done': true},
        ],
      });
      expect(t.subtasks.length, 2);
      expect(t.subtasks[1].done, isTrue);
    });

    test('defaults to empty subtasks when missing', () {
      expect(TaskModel.fromMap('t1', {}).subtasks, isEmpty);
    });
  });

  group('TaskModel.copyWith', () {
    final deadline = DateTime(2025, 12, 31);
    final base = TaskModel(
      id: 't1',
      title: 'Original',
      done: false,
      subtasks: const [],
      deadline: deadline,
    );

    test('changes id', () => expect(base.copyWith(id: 't2').id, 't2'));
    test('changes title', () {
      expect(base.copyWith(title: 'Updated').title, 'Updated');
    });
    test('changes done', () => expect(base.copyWith(done: true).done, isTrue));
    test('changes subtasks', () {
      const subs = [SubTask(title: 'New', done: false)];
      expect(base.copyWith(subtasks: subs).subtasks, subs);
    });
    test('changes deadline', () {
      final d = DateTime(2026, 1, 1);
      expect(base.copyWith(deadline: d).deadline, d);
    });
    test('preserves unchanged fields', () {
      final copy = base.copyWith(title: 'Changed');
      expect(copy.id, 't1');
      expect(copy.done, isFalse);
      expect(copy.deadline, deadline);
    });
  });

  group('TaskModel getters', () {
    const task = TaskModel(
      id: 't1',
      title: 'Assignment',
      done: false,
      subtasks: [
        SubTask(title: 'A', done: true),
        SubTask(title: 'B', done: false),
        SubTask(title: 'C', done: true),
      ],
    );

    const emptyTask = TaskModel(id: 't2', title: 'x', done: false, subtasks: []);

    const allDone = TaskModel(
      id: 't3',
      title: 'y',
      done: true,
      subtasks: [
        SubTask(title: 'A', done: true),
        SubTask(title: 'B', done: true),
      ],
    );

    test('completedSubtasks counts only done subtasks', () {
      expect(task.completedSubtasks, 2);
    });
    test('completedSubtasks is 0 with no subtasks', () {
      expect(emptyTask.completedSubtasks, 0);
    });
    test('completedSubtasks is correct when all are done', () {
      expect(allDone.completedSubtasks, 2);
    });
    test('hasSubtasks is true when subtasks exist', () {
      expect(task.hasSubtasks, isTrue);
    });
    test('hasSubtasks is false for empty list', () {
      expect(emptyTask.hasSubtasks, isFalse);
    });
  });

  // ─── EducationLevel ──────────────────────────────────────────────────────────
  group('EducationLevel.label', () {
    test('shs → Senior High', () {
      expect(EducationLevel.shs.label, 'Senior High');
    });
    test('college → College', () {
      expect(EducationLevel.college.label, 'College');
    });
  });

  group('EducationLevel.trackLabel', () {
    test('shs → Strand', () {
      expect(EducationLevel.shs.trackLabel, 'Strand');
    });
    test('college → Course', () {
      expect(EducationLevel.college.trackLabel, 'Course');
    });
  });

  // ─── UserModel ───────────────────────────────────────────────────────────────
  group('UserModel.fromMap', () {
    test('parses id, name, and email', () {
      final u = UserModel.fromMap('u1', {
        'name': 'Joel',
        'email': 'joel@example.com',
      });
      expect(u.id, 'u1');
      expect(u.name, 'Joel');
      expect(u.email, 'joel@example.com');
    });

    test('defaults name to empty string when missing', () {
      expect(UserModel.fromMap('u1', {}).name, '');
    });

    test('defaults email to empty string when missing', () {
      expect(UserModel.fromMap('u1', {}).email, '');
    });

    test('parses shs level', () {
      expect(
        UserModel.fromMap('u1', {'level': 'shs'}).level,
        EducationLevel.shs,
      );
    });

    test('parses college level', () {
      expect(
        UserModel.fromMap('u1', {'level': 'college'}).level,
        EducationLevel.college,
      );
    });

    test('level is null when missing', () {
      expect(UserModel.fromMap('u1', {}).level, isNull);
    });

    test('level is null for unknown value', () {
      expect(UserModel.fromMap('u1', {'level': 'other'}).level, isNull);
    });

    test('parses track field', () {
      expect(UserModel.fromMap('u1', {'track': 'STEM'}).track, 'STEM');
    });

    test('track is null when missing', () {
      expect(UserModel.fromMap('u1', {}).track, isNull);
    });
  });

  group('UserModel.copyWith', () {
    const base = UserModel(
      id: 'u1',
      name: 'Joel',
      email: 'joel@example.com',
      level: EducationLevel.shs,
      track: 'STEM',
    );

    test('changes id', () => expect(base.copyWith(id: 'u2').id, 'u2'));
    test('changes name', () {
      expect(base.copyWith(name: 'Alice').name, 'Alice');
    });
    test('changes email', () {
      expect(base.copyWith(email: 'alice@x.com').email, 'alice@x.com');
    });
    test('changes level', () {
      expect(
        base.copyWith(level: EducationLevel.college).level,
        EducationLevel.college,
      );
    });
    test('changes track', () {
      expect(base.copyWith(track: 'ABM').track, 'ABM');
    });
    test('preserves unchanged fields', () {
      final copy = base.copyWith(name: 'Bob');
      expect(copy.id, 'u1');
      expect(copy.email, 'joel@example.com');
      expect(copy.level, EducationLevel.shs);
      expect(copy.track, 'STEM');
    });
  });

  group('UserModel.hasTrack', () {
    test('false when level and track are both null', () {
      expect(
        const UserModel(id: 'u1', name: 'A', email: 'a@b.com').hasTrack,
        isFalse,
      );
    });

    test('false when level is set but track is null', () {
      expect(
        const UserModel(
          id: 'u1',
          name: 'A',
          email: 'a@b.com',
          level: EducationLevel.shs,
        ).hasTrack,
        isFalse,
      );
    });

    test('false when track is whitespace only', () {
      expect(
        const UserModel(
          id: 'u1',
          name: 'A',
          email: 'a@b.com',
          level: EducationLevel.shs,
          track: '   ',
        ).hasTrack,
        isFalse,
      );
    });

    test('true when both level and track are set (shs)', () {
      expect(
        const UserModel(
          id: 'u1',
          name: 'A',
          email: 'a@b.com',
          level: EducationLevel.shs,
          track: 'STEM',
        ).hasTrack,
        isTrue,
      );
    });

    test('true when both level and track are set (college)', () {
      expect(
        const UserModel(
          id: 'u1',
          name: 'A',
          email: 'a@b.com',
          level: EducationLevel.college,
          track: 'BS Computer Science',
        ).hasTrack,
        isTrue,
      );
    });
  });

  // ─── SignupState ──────────────────────────────────────────────────────────────
  group('SignupState.isEmailValid', () {
    test('valid email returns true', () {
      expect(const SignupState(email: 'user@example.com').isEmailValid, isTrue);
    });

    test('invalid email returns false', () {
      expect(const SignupState(email: 'not-an-email').isEmailValid, isFalse);
    });

    test('empty email returns false', () {
      expect(const SignupState(email: '').isEmailValid, isFalse);
    });
  });

  group('SignupState.isNameValid', () {
    test('name with 5+ characters is valid', () {
      expect(const SignupState(name: 'Alice').isNameValid, isTrue);
    });

    test('name with fewer than 5 characters is invalid', () {
      expect(const SignupState(name: 'Bob').isNameValid, isFalse);
    });

    test('empty name is invalid', () {
      expect(const SignupState(name: '').isNameValid, isFalse);
    });
  });

  group('SignupState.isPasswordValid', () {
    test('password with 6+ characters is valid', () {
      expect(const SignupState(password: '123456').isPasswordValid, isTrue);
    });

    test('password with fewer than 6 characters is invalid', () {
      expect(const SignupState(password: '123').isPasswordValid, isFalse);
    });

    test('empty password is invalid', () {
      expect(const SignupState(password: '').isPasswordValid, isFalse);
    });
  });

  group('SignupState.doPasswordsMatch', () {
    test('matching passwords return true', () {
      expect(
        const SignupState(
          password: 'pass123',
          confirmPassword: 'pass123',
        ).doPasswordsMatch,
        isTrue,
      );
    });

    test('mismatched passwords return false', () {
      expect(
        const SignupState(
          password: 'abc',
          confirmPassword: 'xyz',
        ).doPasswordsMatch,
        isFalse,
      );
    });

    test('empty password returns false even if confirmPassword also empty', () {
      expect(
        const SignupState(password: '', confirmPassword: '').doPasswordsMatch,
        isFalse,
      );
    });
  });

  group('SignupState.canSubmit', () {
    const valid = SignupState(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'secret1',
      confirmPassword: 'secret1',
    );

    test('true when all fields are valid', () {
      expect(valid.canSubmit, isTrue);
    });

    test('false when passwords do not match', () {
      expect(valid.copyWith(confirmPassword: 'other').canSubmit, isFalse);
    });

    test('false when isSubmitting is true', () {
      expect(valid.copyWith(isSubmitting: true).canSubmit, isFalse);
    });

    test('false when name is too short', () {
      expect(valid.copyWith(name: 'Al').canSubmit, isFalse);
    });

    test('false when email is invalid', () {
      expect(valid.copyWith(email: 'bad').canSubmit, isFalse);
    });

    test('false when password is too short', () {
      expect(
        valid.copyWith(password: '123', confirmPassword: '123').canSubmit,
        isFalse,
      );
    });
  });

  group('SignupState.copyWith', () {
    const base = SignupState(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'pass',
      confirmPassword: 'pass',
      errorMessage: 'Old error',
    );

    test('clears errorMessage when clearError is true', () {
      expect(base.copyWith(clearError: true).errorMessage, isNull);
    });

    test('preserves existing errorMessage when clearError is false', () {
      expect(base.copyWith(name: 'Bob').errorMessage, 'Old error');
    });

    test('sets new errorMessage', () {
      expect(base.copyWith(errorMessage: 'New error').errorMessage, 'New error');
    });

    test('changes obscurePassword', () {
      expect(
        const SignupState(obscurePassword: false)
            .copyWith(obscurePassword: true)
            .obscurePassword,
        isTrue,
      );
    });

    test('changes isSubmitting', () {
      expect(base.copyWith(isSubmitting: true).isSubmitting, isTrue);
    });

    test('changes confirmPassword', () {
      expect(base.copyWith(confirmPassword: 'new').confirmPassword, 'new');
    });
  });
}

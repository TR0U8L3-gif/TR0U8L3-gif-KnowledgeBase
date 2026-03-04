import 'package:knowledge_base/src/knowledge_base/domain/repositories/favorites_repository.dart';
import 'package:knowledge_base/src/knowledge_base/domain/repositories/knowledge_base_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockKnowledgeBaseRepository extends Mock
    implements KnowledgeBaseRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

import '../models/hair_transformation.dart';

abstract class HairTransformationClient {
  Future<HairTransformationOutcome> transform(HairTransformationRequest request);

  void dispose() {}
}

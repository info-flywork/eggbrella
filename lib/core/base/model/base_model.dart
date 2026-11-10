/// Tüm API modellerinin abstract base'i.
abstract class BaseModel<T> {
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

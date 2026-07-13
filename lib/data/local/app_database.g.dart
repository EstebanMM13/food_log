// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RestaurantesTable extends Restaurantes
    with TableInfo<$RestaurantesTable, Restaurante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestaurantesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ubicacionMeta = const VerificationMeta(
    'ubicacion',
  );
  @override
  late final GeneratedColumn<String> ubicacion = GeneratedColumn<String>(
    'ubicacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitasMeta = const VerificationMeta(
    'visitas',
  );
  @override
  late final GeneratedColumn<int> visitas = GeneratedColumn<int>(
    'visitas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    ubicacion,
    visitas,
    notas,
    fotoPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restaurantes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Restaurante> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('ubicacion')) {
      context.handle(
        _ubicacionMeta,
        ubicacion.isAcceptableOrUnknown(data['ubicacion']!, _ubicacionMeta),
      );
    }
    if (data.containsKey('visitas')) {
      context.handle(
        _visitasMeta,
        visitas.isAcceptableOrUnknown(data['visitas']!, _visitasMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Restaurante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Restaurante(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      ubicacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ubicacion'],
      ),
      visitas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visitas'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RestaurantesTable createAlias(String alias) {
    return $RestaurantesTable(attachedDatabase, alias);
  }
}

class Restaurante extends DataClass implements Insertable<Restaurante> {
  final String id;
  final String nombre;
  final String? ubicacion;
  final int visitas;
  final String? notas;

  /// Absolute path to a photo of this restaurant, copied into the app's own
  /// documents directory (see lib/core/photo_storage.dart). Null if no
  /// photo was ever set.
  final String? fotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Restaurante({
    required this.id,
    required this.nombre,
    this.ubicacion,
    required this.visitas,
    this.notas,
    this.fotoPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || ubicacion != null) {
      map['ubicacion'] = Variable<String>(ubicacion);
    }
    map['visitas'] = Variable<int>(visitas);
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RestaurantesCompanion toCompanion(bool nullToAbsent) {
    return RestaurantesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      ubicacion: ubicacion == null && nullToAbsent
          ? const Value.absent()
          : Value(ubicacion),
      visitas: Value(visitas),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Restaurante.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Restaurante(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      ubicacion: serializer.fromJson<String?>(json['ubicacion']),
      visitas: serializer.fromJson<int>(json['visitas']),
      notas: serializer.fromJson<String?>(json['notas']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'ubicacion': serializer.toJson<String?>(ubicacion),
      'visitas': serializer.toJson<int>(visitas),
      'notas': serializer.toJson<String?>(notas),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Restaurante copyWith({
    String? id,
    String? nombre,
    Value<String?> ubicacion = const Value.absent(),
    int? visitas,
    Value<String?> notas = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Restaurante(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    ubicacion: ubicacion.present ? ubicacion.value : this.ubicacion,
    visitas: visitas ?? this.visitas,
    notas: notas.present ? notas.value : this.notas,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Restaurante copyWithCompanion(RestaurantesCompanion data) {
    return Restaurante(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      ubicacion: data.ubicacion.present ? data.ubicacion.value : this.ubicacion,
      visitas: data.visitas.present ? data.visitas.value : this.visitas,
      notas: data.notas.present ? data.notas.value : this.notas,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Restaurante(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('visitas: $visitas, ')
          ..write('notas: $notas, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    ubicacion,
    visitas,
    notas,
    fotoPath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Restaurante &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.ubicacion == this.ubicacion &&
          other.visitas == this.visitas &&
          other.notas == this.notas &&
          other.fotoPath == this.fotoPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RestaurantesCompanion extends UpdateCompanion<Restaurante> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String?> ubicacion;
  final Value<int> visitas;
  final Value<String?> notas;
  final Value<String?> fotoPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RestaurantesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.ubicacion = const Value.absent(),
    this.visitas = const Value.absent(),
    this.notas = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestaurantesCompanion.insert({
    required String id,
    required String nombre,
    this.ubicacion = const Value.absent(),
    this.visitas = const Value.absent(),
    this.notas = const Value.absent(),
    this.fotoPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Restaurante> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? ubicacion,
    Expression<int>? visitas,
    Expression<String>? notas,
    Expression<String>? fotoPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (visitas != null) 'visitas': visitas,
      if (notas != null) 'notas': notas,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestaurantesCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String?>? ubicacion,
    Value<int>? visitas,
    Value<String?>? notas,
    Value<String?>? fotoPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RestaurantesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ubicacion: ubicacion ?? this.ubicacion,
      visitas: visitas ?? this.visitas,
      notas: notas ?? this.notas,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (ubicacion.present) {
      map['ubicacion'] = Variable<String>(ubicacion.value);
    }
    if (visitas.present) {
      map['visitas'] = Variable<int>(visitas.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestaurantesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('visitas: $visitas, ')
          ..write('notas: $notas, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String nombre;
  const Tag({required this.id, required this.nombre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), nombre: Value(nombre));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
    };
  }

  Tag copyWith({String? id, String? nombre}) =>
      Tag(id: id ?? this.id, nombre: nombre ?? this.nombre);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('nombre: $nombre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.nombre == this.nombre);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String nombre,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RestauranteTagsTable extends RestauranteTags
    with TableInfo<$RestauranteTagsTable, RestauranteTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestauranteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _restauranteIdMeta = const VerificationMeta(
    'restauranteId',
  );
  @override
  late final GeneratedColumn<String> restauranteId = GeneratedColumn<String>(
    'restaurante_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES restaurantes (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [restauranteId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restaurante_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestauranteTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('restaurante_id')) {
      context.handle(
        _restauranteIdMeta,
        restauranteId.isAcceptableOrUnknown(
          data['restaurante_id']!,
          _restauranteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restauranteIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {restauranteId, tagId};
  @override
  RestauranteTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestauranteTag(
      restauranteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurante_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $RestauranteTagsTable createAlias(String alias) {
    return $RestauranteTagsTable(attachedDatabase, alias);
  }
}

class RestauranteTag extends DataClass implements Insertable<RestauranteTag> {
  final String restauranteId;
  final String tagId;
  const RestauranteTag({required this.restauranteId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['restaurante_id'] = Variable<String>(restauranteId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  RestauranteTagsCompanion toCompanion(bool nullToAbsent) {
    return RestauranteTagsCompanion(
      restauranteId: Value(restauranteId),
      tagId: Value(tagId),
    );
  }

  factory RestauranteTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestauranteTag(
      restauranteId: serializer.fromJson<String>(json['restauranteId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'restauranteId': serializer.toJson<String>(restauranteId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  RestauranteTag copyWith({String? restauranteId, String? tagId}) =>
      RestauranteTag(
        restauranteId: restauranteId ?? this.restauranteId,
        tagId: tagId ?? this.tagId,
      );
  RestauranteTag copyWithCompanion(RestauranteTagsCompanion data) {
    return RestauranteTag(
      restauranteId: data.restauranteId.present
          ? data.restauranteId.value
          : this.restauranteId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestauranteTag(')
          ..write('restauranteId: $restauranteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(restauranteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestauranteTag &&
          other.restauranteId == this.restauranteId &&
          other.tagId == this.tagId);
}

class RestauranteTagsCompanion extends UpdateCompanion<RestauranteTag> {
  final Value<String> restauranteId;
  final Value<String> tagId;
  final Value<int> rowid;
  const RestauranteTagsCompanion({
    this.restauranteId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestauranteTagsCompanion.insert({
    required String restauranteId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : restauranteId = Value(restauranteId),
       tagId = Value(tagId);
  static Insertable<RestauranteTag> custom({
    Expression<String>? restauranteId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (restauranteId != null) 'restaurante_id': restauranteId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestauranteTagsCompanion copyWith({
    Value<String>? restauranteId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return RestauranteTagsCompanion(
      restauranteId: restauranteId ?? this.restauranteId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (restauranteId.present) {
      map['restaurante_id'] = Variable<String>(restauranteId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestauranteTagsCompanion(')
          ..write('restauranteId: $restauranteId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlatosTable extends Platos with TableInfo<$PlatosTable, Plato> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restauranteIdMeta = const VerificationMeta(
    'restauranteId',
  );
  @override
  late final GeneratedColumn<String> restauranteId = GeneratedColumn<String>(
    'restaurante_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES restaurantes (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puntuacionMeta = const VerificationMeta(
    'puntuacion',
  );
  @override
  late final GeneratedColumn<double> puntuacion = GeneratedColumn<double>(
    'puntuacion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comentarioMeta = const VerificationMeta(
    'comentario',
  );
  @override
  late final GeneratedColumn<String> comentario = GeneratedColumn<String>(
    'comentario',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restauranteId,
    tipo,
    nombre,
    puntuacion,
    comentario,
    fotoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'platos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plato> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurante_id')) {
      context.handle(
        _restauranteIdMeta,
        restauranteId.isAcceptableOrUnknown(
          data['restaurante_id']!,
          _restauranteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restauranteIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('puntuacion')) {
      context.handle(
        _puntuacionMeta,
        puntuacion.isAcceptableOrUnknown(data['puntuacion']!, _puntuacionMeta),
      );
    } else if (isInserting) {
      context.missing(_puntuacionMeta);
    }
    if (data.containsKey('comentario')) {
      context.handle(
        _comentarioMeta,
        comentario.isAcceptableOrUnknown(data['comentario']!, _comentarioMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plato map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plato(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restauranteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurante_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      puntuacion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}puntuacion'],
      )!,
      comentario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comentario'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlatosTable createAlias(String alias) {
    return $PlatosTable(attachedDatabase, alias);
  }
}

class Plato extends DataClass implements Insertable<Plato> {
  final String id;
  final String restauranteId;
  final String tipo;
  final String nombre;
  final double puntuacion;
  final String? comentario;

  /// Absolute path to a photo of this dish, copied into the app's own
  /// documents directory (see lib/core/photo_storage.dart). Null if no
  /// photo was ever set.
  final String? fotoPath;
  final DateTime createdAt;
  const Plato({
    required this.id,
    required this.restauranteId,
    required this.tipo,
    required this.nombre,
    required this.puntuacion,
    this.comentario,
    this.fotoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurante_id'] = Variable<String>(restauranteId);
    map['tipo'] = Variable<String>(tipo);
    map['nombre'] = Variable<String>(nombre);
    map['puntuacion'] = Variable<double>(puntuacion);
    if (!nullToAbsent || comentario != null) {
      map['comentario'] = Variable<String>(comentario);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlatosCompanion toCompanion(bool nullToAbsent) {
    return PlatosCompanion(
      id: Value(id),
      restauranteId: Value(restauranteId),
      tipo: Value(tipo),
      nombre: Value(nombre),
      puntuacion: Value(puntuacion),
      comentario: comentario == null && nullToAbsent
          ? const Value.absent()
          : Value(comentario),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Plato.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plato(
      id: serializer.fromJson<String>(json['id']),
      restauranteId: serializer.fromJson<String>(json['restauranteId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      puntuacion: serializer.fromJson<double>(json['puntuacion']),
      comentario: serializer.fromJson<String?>(json['comentario']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restauranteId': serializer.toJson<String>(restauranteId),
      'tipo': serializer.toJson<String>(tipo),
      'nombre': serializer.toJson<String>(nombre),
      'puntuacion': serializer.toJson<double>(puntuacion),
      'comentario': serializer.toJson<String?>(comentario),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Plato copyWith({
    String? id,
    String? restauranteId,
    String? tipo,
    String? nombre,
    double? puntuacion,
    Value<String?> comentario = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
    DateTime? createdAt,
  }) => Plato(
    id: id ?? this.id,
    restauranteId: restauranteId ?? this.restauranteId,
    tipo: tipo ?? this.tipo,
    nombre: nombre ?? this.nombre,
    puntuacion: puntuacion ?? this.puntuacion,
    comentario: comentario.present ? comentario.value : this.comentario,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Plato copyWithCompanion(PlatosCompanion data) {
    return Plato(
      id: data.id.present ? data.id.value : this.id,
      restauranteId: data.restauranteId.present
          ? data.restauranteId.value
          : this.restauranteId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      puntuacion: data.puntuacion.present
          ? data.puntuacion.value
          : this.puntuacion,
      comentario: data.comentario.present
          ? data.comentario.value
          : this.comentario,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plato(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('puntuacion: $puntuacion, ')
          ..write('comentario: $comentario, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    restauranteId,
    tipo,
    nombre,
    puntuacion,
    comentario,
    fotoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plato &&
          other.id == this.id &&
          other.restauranteId == this.restauranteId &&
          other.tipo == this.tipo &&
          other.nombre == this.nombre &&
          other.puntuacion == this.puntuacion &&
          other.comentario == this.comentario &&
          other.fotoPath == this.fotoPath &&
          other.createdAt == this.createdAt);
}

class PlatosCompanion extends UpdateCompanion<Plato> {
  final Value<String> id;
  final Value<String> restauranteId;
  final Value<String> tipo;
  final Value<String> nombre;
  final Value<double> puntuacion;
  final Value<String?> comentario;
  final Value<String?> fotoPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlatosCompanion({
    this.id = const Value.absent(),
    this.restauranteId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.puntuacion = const Value.absent(),
    this.comentario = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlatosCompanion.insert({
    required String id,
    required String restauranteId,
    required String tipo,
    required String nombre,
    required double puntuacion,
    this.comentario = const Value.absent(),
    this.fotoPath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restauranteId = Value(restauranteId),
       tipo = Value(tipo),
       nombre = Value(nombre),
       puntuacion = Value(puntuacion),
       createdAt = Value(createdAt);
  static Insertable<Plato> custom({
    Expression<String>? id,
    Expression<String>? restauranteId,
    Expression<String>? tipo,
    Expression<String>? nombre,
    Expression<double>? puntuacion,
    Expression<String>? comentario,
    Expression<String>? fotoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restauranteId != null) 'restaurante_id': restauranteId,
      if (tipo != null) 'tipo': tipo,
      if (nombre != null) 'nombre': nombre,
      if (puntuacion != null) 'puntuacion': puntuacion,
      if (comentario != null) 'comentario': comentario,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlatosCompanion copyWith({
    Value<String>? id,
    Value<String>? restauranteId,
    Value<String>? tipo,
    Value<String>? nombre,
    Value<double>? puntuacion,
    Value<String?>? comentario,
    Value<String?>? fotoPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlatosCompanion(
      id: id ?? this.id,
      restauranteId: restauranteId ?? this.restauranteId,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      puntuacion: puntuacion ?? this.puntuacion,
      comentario: comentario ?? this.comentario,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restauranteId.present) {
      map['restaurante_id'] = Variable<String>(restauranteId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (puntuacion.present) {
      map['puntuacion'] = Variable<double>(puntuacion.value);
    }
    if (comentario.present) {
      map['comentario'] = Variable<String>(comentario.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatosCompanion(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('puntuacion: $puntuacion, ')
          ..write('comentario: $comentario, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecordatoriosTable extends Recordatorios
    with TableInfo<$RecordatoriosTable, Recordatorio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordatoriosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restauranteIdMeta = const VerificationMeta(
    'restauranteId',
  );
  @override
  late final GeneratedColumn<String> restauranteId = GeneratedColumn<String>(
    'restaurante_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES restaurantes (id)',
    ),
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hechoMeta = const VerificationMeta('hecho');
  @override
  late final GeneratedColumn<bool> hecho = GeneratedColumn<bool>(
    'hecho',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hecho" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, restauranteId, texto, hecho];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recordatorios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recordatorio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurante_id')) {
      context.handle(
        _restauranteIdMeta,
        restauranteId.isAcceptableOrUnknown(
          data['restaurante_id']!,
          _restauranteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restauranteIdMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('hecho')) {
      context.handle(
        _hechoMeta,
        hecho.isAcceptableOrUnknown(data['hecho']!, _hechoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recordatorio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recordatorio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restauranteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurante_id'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      hecho: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hecho'],
      )!,
    );
  }

  @override
  $RecordatoriosTable createAlias(String alias) {
    return $RecordatoriosTable(attachedDatabase, alias);
  }
}

class Recordatorio extends DataClass implements Insertable<Recordatorio> {
  final String id;
  final String restauranteId;
  final String texto;
  final bool hecho;
  const Recordatorio({
    required this.id,
    required this.restauranteId,
    required this.texto,
    required this.hecho,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurante_id'] = Variable<String>(restauranteId);
    map['texto'] = Variable<String>(texto);
    map['hecho'] = Variable<bool>(hecho);
    return map;
  }

  RecordatoriosCompanion toCompanion(bool nullToAbsent) {
    return RecordatoriosCompanion(
      id: Value(id),
      restauranteId: Value(restauranteId),
      texto: Value(texto),
      hecho: Value(hecho),
    );
  }

  factory Recordatorio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recordatorio(
      id: serializer.fromJson<String>(json['id']),
      restauranteId: serializer.fromJson<String>(json['restauranteId']),
      texto: serializer.fromJson<String>(json['texto']),
      hecho: serializer.fromJson<bool>(json['hecho']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restauranteId': serializer.toJson<String>(restauranteId),
      'texto': serializer.toJson<String>(texto),
      'hecho': serializer.toJson<bool>(hecho),
    };
  }

  Recordatorio copyWith({
    String? id,
    String? restauranteId,
    String? texto,
    bool? hecho,
  }) => Recordatorio(
    id: id ?? this.id,
    restauranteId: restauranteId ?? this.restauranteId,
    texto: texto ?? this.texto,
    hecho: hecho ?? this.hecho,
  );
  Recordatorio copyWithCompanion(RecordatoriosCompanion data) {
    return Recordatorio(
      id: data.id.present ? data.id.value : this.id,
      restauranteId: data.restauranteId.present
          ? data.restauranteId.value
          : this.restauranteId,
      texto: data.texto.present ? data.texto.value : this.texto,
      hecho: data.hecho.present ? data.hecho.value : this.hecho,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recordatorio(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('texto: $texto, ')
          ..write('hecho: $hecho')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, restauranteId, texto, hecho);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recordatorio &&
          other.id == this.id &&
          other.restauranteId == this.restauranteId &&
          other.texto == this.texto &&
          other.hecho == this.hecho);
}

class RecordatoriosCompanion extends UpdateCompanion<Recordatorio> {
  final Value<String> id;
  final Value<String> restauranteId;
  final Value<String> texto;
  final Value<bool> hecho;
  final Value<int> rowid;
  const RecordatoriosCompanion({
    this.id = const Value.absent(),
    this.restauranteId = const Value.absent(),
    this.texto = const Value.absent(),
    this.hecho = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecordatoriosCompanion.insert({
    required String id,
    required String restauranteId,
    required String texto,
    this.hecho = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restauranteId = Value(restauranteId),
       texto = Value(texto);
  static Insertable<Recordatorio> custom({
    Expression<String>? id,
    Expression<String>? restauranteId,
    Expression<String>? texto,
    Expression<bool>? hecho,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restauranteId != null) 'restaurante_id': restauranteId,
      if (texto != null) 'texto': texto,
      if (hecho != null) 'hecho': hecho,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecordatoriosCompanion copyWith({
    Value<String>? id,
    Value<String>? restauranteId,
    Value<String>? texto,
    Value<bool>? hecho,
    Value<int>? rowid,
  }) {
    return RecordatoriosCompanion(
      id: id ?? this.id,
      restauranteId: restauranteId ?? this.restauranteId,
      texto: texto ?? this.texto,
      hecho: hecho ?? this.hecho,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restauranteId.present) {
      map['restaurante_id'] = Variable<String>(restauranteId.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (hecho.present) {
      map['hecho'] = Variable<bool>(hecho.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordatoriosCompanion(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('texto: $texto, ')
          ..write('hecho: $hecho, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restauranteIdMeta = const VerificationMeta(
    'restauranteId',
  );
  @override
  late final GeneratedColumn<String> restauranteId = GeneratedColumn<String>(
    'restaurante_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES restaurantes (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, restauranteId, nombre, orden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurante_id')) {
      context.handle(
        _restauranteIdMeta,
        restauranteId.isAcceptableOrUnknown(
          data['restaurante_id']!,
          _restauranteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restauranteIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restauranteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurante_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final String id;
  final String restauranteId;
  final String nombre;
  final int orden;
  const Categoria({
    required this.id,
    required this.restauranteId,
    required this.nombre,
    required this.orden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurante_id'] = Variable<String>(restauranteId);
    map['nombre'] = Variable<String>(nombre);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      restauranteId: Value(restauranteId),
      nombre: Value(nombre),
      orden: Value(orden),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<String>(json['id']),
      restauranteId: serializer.fromJson<String>(json['restauranteId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restauranteId': serializer.toJson<String>(restauranteId),
      'nombre': serializer.toJson<String>(nombre),
      'orden': serializer.toJson<int>(orden),
    };
  }

  Categoria copyWith({
    String? id,
    String? restauranteId,
    String? nombre,
    int? orden,
  }) => Categoria(
    id: id ?? this.id,
    restauranteId: restauranteId ?? this.restauranteId,
    nombre: nombre ?? this.nombre,
    orden: orden ?? this.orden,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      restauranteId: data.restauranteId.present
          ? data.restauranteId.value
          : this.restauranteId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('nombre: $nombre, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, restauranteId, nombre, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.restauranteId == this.restauranteId &&
          other.nombre == this.nombre &&
          other.orden == this.orden);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<String> id;
  final Value<String> restauranteId;
  final Value<String> nombre;
  final Value<int> orden;
  final Value<int> rowid;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.restauranteId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.orden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriasCompanion.insert({
    required String id,
    required String restauranteId,
    required String nombre,
    this.orden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restauranteId = Value(restauranteId),
       nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<String>? id,
    Expression<String>? restauranteId,
    Expression<String>? nombre,
    Expression<int>? orden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restauranteId != null) 'restaurante_id': restauranteId,
      if (nombre != null) 'nombre': nombre,
      if (orden != null) 'orden': orden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriasCompanion copyWith({
    Value<String>? id,
    Value<String>? restauranteId,
    Value<String>? nombre,
    Value<int>? orden,
    Value<int>? rowid,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      restauranteId: restauranteId ?? this.restauranteId,
      nombre: nombre ?? this.nombre,
      orden: orden ?? this.orden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restauranteId.present) {
      map['restaurante_id'] = Variable<String>(restauranteId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('restauranteId: $restauranteId, ')
          ..write('nombre: $nombre, ')
          ..write('orden: $orden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RestaurantesTable restaurantes = $RestaurantesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $RestauranteTagsTable restauranteTags = $RestauranteTagsTable(
    this,
  );
  late final $PlatosTable platos = $PlatosTable(this);
  late final $RecordatoriosTable recordatorios = $RecordatoriosTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    restaurantes,
    tags,
    restauranteTags,
    platos,
    recordatorios,
    categorias,
  ];
}

typedef $$RestaurantesTableCreateCompanionBuilder =
    RestaurantesCompanion Function({
      required String id,
      required String nombre,
      Value<String?> ubicacion,
      Value<int> visitas,
      Value<String?> notas,
      Value<String?> fotoPath,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RestaurantesTableUpdateCompanionBuilder =
    RestaurantesCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String?> ubicacion,
      Value<int> visitas,
      Value<String?> notas,
      Value<String?> fotoPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RestaurantesTableReferences
    extends BaseReferences<_$AppDatabase, $RestaurantesTable, Restaurante> {
  $$RestaurantesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RestauranteTagsTable, List<RestauranteTag>>
  _restauranteTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.restauranteTags,
    aliasName: $_aliasNameGenerator(
      db.restaurantes.id,
      db.restauranteTags.restauranteId,
    ),
  );

  $$RestauranteTagsTableProcessedTableManager get restauranteTagsRefs {
    final manager = $$RestauranteTagsTableTableManager(
      $_db,
      $_db.restauranteTags,
    ).filter((f) => f.restauranteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _restauranteTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlatosTable, List<Plato>> _platosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.platos,
    aliasName: $_aliasNameGenerator(
      db.restaurantes.id,
      db.platos.restauranteId,
    ),
  );

  $$PlatosTableProcessedTableManager get platosRefs {
    final manager = $$PlatosTableTableManager(
      $_db,
      $_db.platos,
    ).filter((f) => f.restauranteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_platosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecordatoriosTable, List<Recordatorio>>
  _recordatoriosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recordatorios,
    aliasName: $_aliasNameGenerator(
      db.restaurantes.id,
      db.recordatorios.restauranteId,
    ),
  );

  $$RecordatoriosTableProcessedTableManager get recordatoriosRefs {
    final manager = $$RecordatoriosTableTableManager(
      $_db,
      $_db.recordatorios,
    ).filter((f) => f.restauranteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recordatoriosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoriasTable, List<Categoria>>
  _categoriasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categorias,
    aliasName: $_aliasNameGenerator(
      db.restaurantes.id,
      db.categorias.restauranteId,
    ),
  );

  $$CategoriasTableProcessedTableManager get categoriasRefs {
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.restauranteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RestaurantesTableFilterComposer
    extends Composer<_$AppDatabase, $RestaurantesTable> {
  $$RestaurantesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitas => $composableBuilder(
    column: $table.visitas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> restauranteTagsRefs(
    Expression<bool> Function($$RestauranteTagsTableFilterComposer f) f,
  ) {
    final $$RestauranteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restauranteTags,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestauranteTagsTableFilterComposer(
            $db: $db,
            $table: $db.restauranteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> platosRefs(
    Expression<bool> Function($$PlatosTableFilterComposer f) f,
  ) {
    final $$PlatosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platos,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatosTableFilterComposer(
            $db: $db,
            $table: $db.platos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recordatoriosRefs(
    Expression<bool> Function($$RecordatoriosTableFilterComposer f) f,
  ) {
    final $$RecordatoriosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recordatorios,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordatoriosTableFilterComposer(
            $db: $db,
            $table: $db.recordatorios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoriasRefs(
    Expression<bool> Function($$CategoriasTableFilterComposer f) f,
  ) {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RestaurantesTableOrderingComposer
    extends Composer<_$AppDatabase, $RestaurantesTable> {
  $$RestaurantesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitas => $composableBuilder(
    column: $table.visitas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RestaurantesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestaurantesTable> {
  $$RestaurantesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get ubicacion =>
      $composableBuilder(column: $table.ubicacion, builder: (column) => column);

  GeneratedColumn<int> get visitas =>
      $composableBuilder(column: $table.visitas, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> restauranteTagsRefs<T extends Object>(
    Expression<T> Function($$RestauranteTagsTableAnnotationComposer a) f,
  ) {
    final $$RestauranteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restauranteTags,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestauranteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.restauranteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> platosRefs<T extends Object>(
    Expression<T> Function($$PlatosTableAnnotationComposer a) f,
  ) {
    final $$PlatosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platos,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatosTableAnnotationComposer(
            $db: $db,
            $table: $db.platos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recordatoriosRefs<T extends Object>(
    Expression<T> Function($$RecordatoriosTableAnnotationComposer a) f,
  ) {
    final $$RecordatoriosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recordatorios,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordatoriosTableAnnotationComposer(
            $db: $db,
            $table: $db.recordatorios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoriasRefs<T extends Object>(
    Expression<T> Function($$CategoriasTableAnnotationComposer a) f,
  ) {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.restauranteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RestaurantesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestaurantesTable,
          Restaurante,
          $$RestaurantesTableFilterComposer,
          $$RestaurantesTableOrderingComposer,
          $$RestaurantesTableAnnotationComposer,
          $$RestaurantesTableCreateCompanionBuilder,
          $$RestaurantesTableUpdateCompanionBuilder,
          (Restaurante, $$RestaurantesTableReferences),
          Restaurante,
          PrefetchHooks Function({
            bool restauranteTagsRefs,
            bool platosRefs,
            bool recordatoriosRefs,
            bool categoriasRefs,
          })
        > {
  $$RestaurantesTableTableManager(_$AppDatabase db, $RestaurantesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestaurantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestaurantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestaurantesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> ubicacion = const Value.absent(),
                Value<int> visitas = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestaurantesCompanion(
                id: id,
                nombre: nombre,
                ubicacion: ubicacion,
                visitas: visitas,
                notas: notas,
                fotoPath: fotoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                Value<String?> ubicacion = const Value.absent(),
                Value<int> visitas = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RestaurantesCompanion.insert(
                id: id,
                nombre: nombre,
                ubicacion: ubicacion,
                visitas: visitas,
                notas: notas,
                fotoPath: fotoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RestaurantesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                restauranteTagsRefs = false,
                platosRefs = false,
                recordatoriosRefs = false,
                categoriasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (restauranteTagsRefs) db.restauranteTags,
                    if (platosRefs) db.platos,
                    if (recordatoriosRefs) db.recordatorios,
                    if (categoriasRefs) db.categorias,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (restauranteTagsRefs)
                        await $_getPrefetchedData<
                          Restaurante,
                          $RestaurantesTable,
                          RestauranteTag
                        >(
                          currentTable: table,
                          referencedTable: $$RestaurantesTableReferences
                              ._restauranteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RestaurantesTableReferences(
                                db,
                                table,
                                p0,
                              ).restauranteTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.restauranteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (platosRefs)
                        await $_getPrefetchedData<
                          Restaurante,
                          $RestaurantesTable,
                          Plato
                        >(
                          currentTable: table,
                          referencedTable: $$RestaurantesTableReferences
                              ._platosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RestaurantesTableReferences(
                                db,
                                table,
                                p0,
                              ).platosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.restauranteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recordatoriosRefs)
                        await $_getPrefetchedData<
                          Restaurante,
                          $RestaurantesTable,
                          Recordatorio
                        >(
                          currentTable: table,
                          referencedTable: $$RestaurantesTableReferences
                              ._recordatoriosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RestaurantesTableReferences(
                                db,
                                table,
                                p0,
                              ).recordatoriosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.restauranteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoriasRefs)
                        await $_getPrefetchedData<
                          Restaurante,
                          $RestaurantesTable,
                          Categoria
                        >(
                          currentTable: table,
                          referencedTable: $$RestaurantesTableReferences
                              ._categoriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RestaurantesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.restauranteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RestaurantesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestaurantesTable,
      Restaurante,
      $$RestaurantesTableFilterComposer,
      $$RestaurantesTableOrderingComposer,
      $$RestaurantesTableAnnotationComposer,
      $$RestaurantesTableCreateCompanionBuilder,
      $$RestaurantesTableUpdateCompanionBuilder,
      (Restaurante, $$RestaurantesTableReferences),
      Restaurante,
      PrefetchHooks Function({
        bool restauranteTagsRefs,
        bool platosRefs,
        bool recordatoriosRefs,
        bool categoriasRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String nombre,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RestauranteTagsTable, List<RestauranteTag>>
  _restauranteTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.restauranteTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.restauranteTags.tagId),
  );

  $$RestauranteTagsTableProcessedTableManager get restauranteTagsRefs {
    final manager = $$RestauranteTagsTableTableManager(
      $_db,
      $_db.restauranteTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _restauranteTagsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> restauranteTagsRefs(
    Expression<bool> Function($$RestauranteTagsTableFilterComposer f) f,
  ) {
    final $$RestauranteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restauranteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestauranteTagsTableFilterComposer(
            $db: $db,
            $table: $db.restauranteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  Expression<T> restauranteTagsRefs<T extends Object>(
    Expression<T> Function($$RestauranteTagsTableAnnotationComposer a) f,
  ) {
    final $$RestauranteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restauranteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestauranteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.restauranteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool restauranteTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(id: id, nombre: nombre, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(id: id, nombre: nombre, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({restauranteTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (restauranteTagsRefs) db.restauranteTags,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (restauranteTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, RestauranteTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._restauranteTagsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TagsTableReferences(
                        db,
                        table,
                        p0,
                      ).restauranteTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool restauranteTagsRefs})
    >;
typedef $$RestauranteTagsTableCreateCompanionBuilder =
    RestauranteTagsCompanion Function({
      required String restauranteId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$RestauranteTagsTableUpdateCompanionBuilder =
    RestauranteTagsCompanion Function({
      Value<String> restauranteId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$RestauranteTagsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RestauranteTagsTable, RestauranteTag> {
  $$RestauranteTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RestaurantesTable _restauranteIdTable(_$AppDatabase db) =>
      db.restaurantes.createAlias(
        $_aliasNameGenerator(
          db.restauranteTags.restauranteId,
          db.restaurantes.id,
        ),
      );

  $$RestaurantesTableProcessedTableManager get restauranteId {
    final $_column = $_itemColumn<String>('restaurante_id')!;

    final manager = $$RestaurantesTableTableManager(
      $_db,
      $_db.restaurantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restauranteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.restauranteTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RestauranteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $RestauranteTagsTable> {
  $$RestauranteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RestaurantesTableFilterComposer get restauranteId {
    final $$RestaurantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableFilterComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestauranteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $RestauranteTagsTable> {
  $$RestauranteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RestaurantesTableOrderingComposer get restauranteId {
    final $$RestaurantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableOrderingComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestauranteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestauranteTagsTable> {
  $$RestauranteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$RestaurantesTableAnnotationComposer get restauranteId {
    final $$RestaurantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableAnnotationComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestauranteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestauranteTagsTable,
          RestauranteTag,
          $$RestauranteTagsTableFilterComposer,
          $$RestauranteTagsTableOrderingComposer,
          $$RestauranteTagsTableAnnotationComposer,
          $$RestauranteTagsTableCreateCompanionBuilder,
          $$RestauranteTagsTableUpdateCompanionBuilder,
          (RestauranteTag, $$RestauranteTagsTableReferences),
          RestauranteTag,
          PrefetchHooks Function({bool restauranteId, bool tagId})
        > {
  $$RestauranteTagsTableTableManager(
    _$AppDatabase db,
    $RestauranteTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestauranteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestauranteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestauranteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> restauranteId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestauranteTagsCompanion(
                restauranteId: restauranteId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String restauranteId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => RestauranteTagsCompanion.insert(
                restauranteId: restauranteId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RestauranteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({restauranteId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (restauranteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.restauranteId,
                                referencedTable:
                                    $$RestauranteTagsTableReferences
                                        ._restauranteIdTable(db),
                                referencedColumn:
                                    $$RestauranteTagsTableReferences
                                        ._restauranteIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$RestauranteTagsTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$RestauranteTagsTableReferences
                                        ._tagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RestauranteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestauranteTagsTable,
      RestauranteTag,
      $$RestauranteTagsTableFilterComposer,
      $$RestauranteTagsTableOrderingComposer,
      $$RestauranteTagsTableAnnotationComposer,
      $$RestauranteTagsTableCreateCompanionBuilder,
      $$RestauranteTagsTableUpdateCompanionBuilder,
      (RestauranteTag, $$RestauranteTagsTableReferences),
      RestauranteTag,
      PrefetchHooks Function({bool restauranteId, bool tagId})
    >;
typedef $$PlatosTableCreateCompanionBuilder =
    PlatosCompanion Function({
      required String id,
      required String restauranteId,
      required String tipo,
      required String nombre,
      required double puntuacion,
      Value<String?> comentario,
      Value<String?> fotoPath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlatosTableUpdateCompanionBuilder =
    PlatosCompanion Function({
      Value<String> id,
      Value<String> restauranteId,
      Value<String> tipo,
      Value<String> nombre,
      Value<double> puntuacion,
      Value<String?> comentario,
      Value<String?> fotoPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlatosTableReferences
    extends BaseReferences<_$AppDatabase, $PlatosTable, Plato> {
  $$PlatosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RestaurantesTable _restauranteIdTable(_$AppDatabase db) =>
      db.restaurantes.createAlias(
        $_aliasNameGenerator(db.platos.restauranteId, db.restaurantes.id),
      );

  $$RestaurantesTableProcessedTableManager get restauranteId {
    final $_column = $_itemColumn<String>('restaurante_id')!;

    final manager = $$RestaurantesTableTableManager(
      $_db,
      $_db.restaurantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restauranteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlatosTableFilterComposer
    extends Composer<_$AppDatabase, $PlatosTable> {
  $$PlatosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RestaurantesTableFilterComposer get restauranteId {
    final $$RestaurantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableFilterComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatosTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatosTable> {
  $$PlatosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RestaurantesTableOrderingComposer get restauranteId {
    final $$RestaurantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableOrderingComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatosTable> {
  $$PlatosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comentario => $composableBuilder(
    column: $table.comentario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RestaurantesTableAnnotationComposer get restauranteId {
    final $$RestaurantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableAnnotationComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatosTable,
          Plato,
          $$PlatosTableFilterComposer,
          $$PlatosTableOrderingComposer,
          $$PlatosTableAnnotationComposer,
          $$PlatosTableCreateCompanionBuilder,
          $$PlatosTableUpdateCompanionBuilder,
          (Plato, $$PlatosTableReferences),
          Plato,
          PrefetchHooks Function({bool restauranteId})
        > {
  $$PlatosTableTableManager(_$AppDatabase db, $PlatosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restauranteId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> puntuacion = const Value.absent(),
                Value<String?> comentario = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatosCompanion(
                id: id,
                restauranteId: restauranteId,
                tipo: tipo,
                nombre: nombre,
                puntuacion: puntuacion,
                comentario: comentario,
                fotoPath: fotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restauranteId,
                required String tipo,
                required String nombre,
                required double puntuacion,
                Value<String?> comentario = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlatosCompanion.insert(
                id: id,
                restauranteId: restauranteId,
                tipo: tipo,
                nombre: nombre,
                puntuacion: puntuacion,
                comentario: comentario,
                fotoPath: fotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlatosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({restauranteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (restauranteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.restauranteId,
                                referencedTable: $$PlatosTableReferences
                                    ._restauranteIdTable(db),
                                referencedColumn: $$PlatosTableReferences
                                    ._restauranteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlatosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatosTable,
      Plato,
      $$PlatosTableFilterComposer,
      $$PlatosTableOrderingComposer,
      $$PlatosTableAnnotationComposer,
      $$PlatosTableCreateCompanionBuilder,
      $$PlatosTableUpdateCompanionBuilder,
      (Plato, $$PlatosTableReferences),
      Plato,
      PrefetchHooks Function({bool restauranteId})
    >;
typedef $$RecordatoriosTableCreateCompanionBuilder =
    RecordatoriosCompanion Function({
      required String id,
      required String restauranteId,
      required String texto,
      Value<bool> hecho,
      Value<int> rowid,
    });
typedef $$RecordatoriosTableUpdateCompanionBuilder =
    RecordatoriosCompanion Function({
      Value<String> id,
      Value<String> restauranteId,
      Value<String> texto,
      Value<bool> hecho,
      Value<int> rowid,
    });

final class $$RecordatoriosTableReferences
    extends BaseReferences<_$AppDatabase, $RecordatoriosTable, Recordatorio> {
  $$RecordatoriosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RestaurantesTable _restauranteIdTable(_$AppDatabase db) =>
      db.restaurantes.createAlias(
        $_aliasNameGenerator(
          db.recordatorios.restauranteId,
          db.restaurantes.id,
        ),
      );

  $$RestaurantesTableProcessedTableManager get restauranteId {
    final $_column = $_itemColumn<String>('restaurante_id')!;

    final manager = $$RestaurantesTableTableManager(
      $_db,
      $_db.restaurantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restauranteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecordatoriosTableFilterComposer
    extends Composer<_$AppDatabase, $RecordatoriosTable> {
  $$RecordatoriosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hecho => $composableBuilder(
    column: $table.hecho,
    builder: (column) => ColumnFilters(column),
  );

  $$RestaurantesTableFilterComposer get restauranteId {
    final $$RestaurantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableFilterComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordatoriosTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordatoriosTable> {
  $$RecordatoriosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hecho => $composableBuilder(
    column: $table.hecho,
    builder: (column) => ColumnOrderings(column),
  );

  $$RestaurantesTableOrderingComposer get restauranteId {
    final $$RestaurantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableOrderingComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordatoriosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordatoriosTable> {
  $$RecordatoriosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<bool> get hecho =>
      $composableBuilder(column: $table.hecho, builder: (column) => column);

  $$RestaurantesTableAnnotationComposer get restauranteId {
    final $$RestaurantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableAnnotationComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordatoriosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordatoriosTable,
          Recordatorio,
          $$RecordatoriosTableFilterComposer,
          $$RecordatoriosTableOrderingComposer,
          $$RecordatoriosTableAnnotationComposer,
          $$RecordatoriosTableCreateCompanionBuilder,
          $$RecordatoriosTableUpdateCompanionBuilder,
          (Recordatorio, $$RecordatoriosTableReferences),
          Recordatorio,
          PrefetchHooks Function({bool restauranteId})
        > {
  $$RecordatoriosTableTableManager(_$AppDatabase db, $RecordatoriosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordatoriosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordatoriosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordatoriosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restauranteId = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<bool> hecho = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordatoriosCompanion(
                id: id,
                restauranteId: restauranteId,
                texto: texto,
                hecho: hecho,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restauranteId,
                required String texto,
                Value<bool> hecho = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordatoriosCompanion.insert(
                id: id,
                restauranteId: restauranteId,
                texto: texto,
                hecho: hecho,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecordatoriosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({restauranteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (restauranteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.restauranteId,
                                referencedTable: $$RecordatoriosTableReferences
                                    ._restauranteIdTable(db),
                                referencedColumn: $$RecordatoriosTableReferences
                                    ._restauranteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecordatoriosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordatoriosTable,
      Recordatorio,
      $$RecordatoriosTableFilterComposer,
      $$RecordatoriosTableOrderingComposer,
      $$RecordatoriosTableAnnotationComposer,
      $$RecordatoriosTableCreateCompanionBuilder,
      $$RecordatoriosTableUpdateCompanionBuilder,
      (Recordatorio, $$RecordatoriosTableReferences),
      Recordatorio,
      PrefetchHooks Function({bool restauranteId})
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      required String id,
      required String restauranteId,
      required String nombre,
      Value<int> orden,
      Value<int> rowid,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<String> id,
      Value<String> restauranteId,
      Value<String> nombre,
      Value<int> orden,
      Value<int> rowid,
    });

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RestaurantesTable _restauranteIdTable(_$AppDatabase db) =>
      db.restaurantes.createAlias(
        $_aliasNameGenerator(db.categorias.restauranteId, db.restaurantes.id),
      );

  $$RestaurantesTableProcessedTableManager get restauranteId {
    final $_column = $_itemColumn<String>('restaurante_id')!;

    final manager = $$RestaurantesTableTableManager(
      $_db,
      $_db.restaurantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restauranteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  $$RestaurantesTableFilterComposer get restauranteId {
    final $$RestaurantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableFilterComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  $$RestaurantesTableOrderingComposer get restauranteId {
    final $$RestaurantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableOrderingComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  $$RestaurantesTableAnnotationComposer get restauranteId {
    final $$RestaurantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restauranteId,
      referencedTable: $db.restaurantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantesTableAnnotationComposer(
            $db: $db,
            $table: $db.restaurantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, $$CategoriasTableReferences),
          Categoria,
          PrefetchHooks Function({bool restauranteId})
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restauranteId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                restauranteId: restauranteId,
                nombre: nombre,
                orden: orden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restauranteId,
                required String nombre,
                Value<int> orden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                restauranteId: restauranteId,
                nombre: nombre,
                orden: orden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({restauranteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (restauranteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.restauranteId,
                                referencedTable: $$CategoriasTableReferences
                                    ._restauranteIdTable(db),
                                referencedColumn: $$CategoriasTableReferences
                                    ._restauranteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, $$CategoriasTableReferences),
      Categoria,
      PrefetchHooks Function({bool restauranteId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RestaurantesTableTableManager get restaurantes =>
      $$RestaurantesTableTableManager(_db, _db.restaurantes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$RestauranteTagsTableTableManager get restauranteTags =>
      $$RestauranteTagsTableTableManager(_db, _db.restauranteTags);
  $$PlatosTableTableManager get platos =>
      $$PlatosTableTableManager(_db, _db.platos);
  $$RecordatoriosTableTableManager get recordatorios =>
      $$RecordatoriosTableTableManager(_db, _db.recordatorios);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
}

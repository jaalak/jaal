// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FeedsTable extends Feeds with TableInfo<$FeedsTable, FeedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latestSeqMeta = const VerificationMeta(
    'latestSeq',
  );
  @override
  late final GeneratedColumn<int> latestSeq = GeneratedColumn<int>(
    'latest_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latestIdMeta = const VerificationMeta(
    'latestId',
  );
  @override
  late final GeneratedColumn<String> latestId = GeneratedColumn<String>(
    'latest_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestLamportMeta = const VerificationMeta(
    'latestLamport',
  );
  @override
  late final GeneratedColumn<int> latestLamport = GeneratedColumn<int>(
    'latest_lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revokedAfterSeqMeta = const VerificationMeta(
    'revokedAfterSeq',
  );
  @override
  late final GeneratedColumn<int> revokedAfterSeq = GeneratedColumn<int>(
    'revoked_after_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<int> purpose = GeneratedColumn<int>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    feedId,
    rootId,
    latestSeq,
    latestId,
    latestLamport,
    revokedAfterSeq,
    purpose,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('latest_seq')) {
      context.handle(
        _latestSeqMeta,
        latestSeq.isAcceptableOrUnknown(data['latest_seq']!, _latestSeqMeta),
      );
    }
    if (data.containsKey('latest_id')) {
      context.handle(
        _latestIdMeta,
        latestId.isAcceptableOrUnknown(data['latest_id']!, _latestIdMeta),
      );
    }
    if (data.containsKey('latest_lamport')) {
      context.handle(
        _latestLamportMeta,
        latestLamport.isAcceptableOrUnknown(
          data['latest_lamport']!,
          _latestLamportMeta,
        ),
      );
    }
    if (data.containsKey('revoked_after_seq')) {
      context.handle(
        _revokedAfterSeqMeta,
        revokedAfterSeq.isAcceptableOrUnknown(
          data['revoked_after_seq']!,
          _revokedAfterSeqMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedId};
  @override
  FeedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedRow(
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      latestSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_seq'],
      )!,
      latestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_id'],
      ),
      latestLamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_lamport'],
      )!,
      revokedAfterSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revoked_after_seq'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purpose'],
      )!,
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }
}

class FeedRow extends DataClass implements Insertable<FeedRow> {
  final String feedId;
  final String rootId;
  final int latestSeq;
  final String? latestId;
  final int latestLamport;

  /// Set by `device.revoke`: events with seq > this are ignored.
  final int? revokedAfterSeq;

  /// [FeedPurpose]: 0 = normal device feed, 1 = moderation feed (v4).
  final int purpose;
  const FeedRow({
    required this.feedId,
    required this.rootId,
    required this.latestSeq,
    this.latestId,
    required this.latestLamport,
    this.revokedAfterSeq,
    required this.purpose,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_id'] = Variable<String>(feedId);
    map['root_id'] = Variable<String>(rootId);
    map['latest_seq'] = Variable<int>(latestSeq);
    if (!nullToAbsent || latestId != null) {
      map['latest_id'] = Variable<String>(latestId);
    }
    map['latest_lamport'] = Variable<int>(latestLamport);
    if (!nullToAbsent || revokedAfterSeq != null) {
      map['revoked_after_seq'] = Variable<int>(revokedAfterSeq);
    }
    map['purpose'] = Variable<int>(purpose);
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      feedId: Value(feedId),
      rootId: Value(rootId),
      latestSeq: Value(latestSeq),
      latestId: latestId == null && nullToAbsent
          ? const Value.absent()
          : Value(latestId),
      latestLamport: Value(latestLamport),
      revokedAfterSeq: revokedAfterSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAfterSeq),
      purpose: Value(purpose),
    );
  }

  factory FeedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedRow(
      feedId: serializer.fromJson<String>(json['feedId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      latestSeq: serializer.fromJson<int>(json['latestSeq']),
      latestId: serializer.fromJson<String?>(json['latestId']),
      latestLamport: serializer.fromJson<int>(json['latestLamport']),
      revokedAfterSeq: serializer.fromJson<int?>(json['revokedAfterSeq']),
      purpose: serializer.fromJson<int>(json['purpose']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedId': serializer.toJson<String>(feedId),
      'rootId': serializer.toJson<String>(rootId),
      'latestSeq': serializer.toJson<int>(latestSeq),
      'latestId': serializer.toJson<String?>(latestId),
      'latestLamport': serializer.toJson<int>(latestLamport),
      'revokedAfterSeq': serializer.toJson<int?>(revokedAfterSeq),
      'purpose': serializer.toJson<int>(purpose),
    };
  }

  FeedRow copyWith({
    String? feedId,
    String? rootId,
    int? latestSeq,
    Value<String?> latestId = const Value.absent(),
    int? latestLamport,
    Value<int?> revokedAfterSeq = const Value.absent(),
    int? purpose,
  }) => FeedRow(
    feedId: feedId ?? this.feedId,
    rootId: rootId ?? this.rootId,
    latestSeq: latestSeq ?? this.latestSeq,
    latestId: latestId.present ? latestId.value : this.latestId,
    latestLamport: latestLamport ?? this.latestLamport,
    revokedAfterSeq: revokedAfterSeq.present
        ? revokedAfterSeq.value
        : this.revokedAfterSeq,
    purpose: purpose ?? this.purpose,
  );
  FeedRow copyWithCompanion(FeedsCompanion data) {
    return FeedRow(
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      latestSeq: data.latestSeq.present ? data.latestSeq.value : this.latestSeq,
      latestId: data.latestId.present ? data.latestId.value : this.latestId,
      latestLamport: data.latestLamport.present
          ? data.latestLamport.value
          : this.latestLamport,
      revokedAfterSeq: data.revokedAfterSeq.present
          ? data.revokedAfterSeq.value
          : this.revokedAfterSeq,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedRow(')
          ..write('feedId: $feedId, ')
          ..write('rootId: $rootId, ')
          ..write('latestSeq: $latestSeq, ')
          ..write('latestId: $latestId, ')
          ..write('latestLamport: $latestLamport, ')
          ..write('revokedAfterSeq: $revokedAfterSeq, ')
          ..write('purpose: $purpose')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    feedId,
    rootId,
    latestSeq,
    latestId,
    latestLamport,
    revokedAfterSeq,
    purpose,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedRow &&
          other.feedId == this.feedId &&
          other.rootId == this.rootId &&
          other.latestSeq == this.latestSeq &&
          other.latestId == this.latestId &&
          other.latestLamport == this.latestLamport &&
          other.revokedAfterSeq == this.revokedAfterSeq &&
          other.purpose == this.purpose);
}

class FeedsCompanion extends UpdateCompanion<FeedRow> {
  final Value<String> feedId;
  final Value<String> rootId;
  final Value<int> latestSeq;
  final Value<String?> latestId;
  final Value<int> latestLamport;
  final Value<int?> revokedAfterSeq;
  final Value<int> purpose;
  final Value<int> rowid;
  const FeedsCompanion({
    this.feedId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.latestSeq = const Value.absent(),
    this.latestId = const Value.absent(),
    this.latestLamport = const Value.absent(),
    this.revokedAfterSeq = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedsCompanion.insert({
    required String feedId,
    required String rootId,
    this.latestSeq = const Value.absent(),
    this.latestId = const Value.absent(),
    this.latestLamport = const Value.absent(),
    this.revokedAfterSeq = const Value.absent(),
    this.purpose = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedId = Value(feedId),
       rootId = Value(rootId);
  static Insertable<FeedRow> custom({
    Expression<String>? feedId,
    Expression<String>? rootId,
    Expression<int>? latestSeq,
    Expression<String>? latestId,
    Expression<int>? latestLamport,
    Expression<int>? revokedAfterSeq,
    Expression<int>? purpose,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedId != null) 'feed_id': feedId,
      if (rootId != null) 'root_id': rootId,
      if (latestSeq != null) 'latest_seq': latestSeq,
      if (latestId != null) 'latest_id': latestId,
      if (latestLamport != null) 'latest_lamport': latestLamport,
      if (revokedAfterSeq != null) 'revoked_after_seq': revokedAfterSeq,
      if (purpose != null) 'purpose': purpose,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedsCompanion copyWith({
    Value<String>? feedId,
    Value<String>? rootId,
    Value<int>? latestSeq,
    Value<String?>? latestId,
    Value<int>? latestLamport,
    Value<int?>? revokedAfterSeq,
    Value<int>? purpose,
    Value<int>? rowid,
  }) {
    return FeedsCompanion(
      feedId: feedId ?? this.feedId,
      rootId: rootId ?? this.rootId,
      latestSeq: latestSeq ?? this.latestSeq,
      latestId: latestId ?? this.latestId,
      latestLamport: latestLamport ?? this.latestLamport,
      revokedAfterSeq: revokedAfterSeq ?? this.revokedAfterSeq,
      purpose: purpose ?? this.purpose,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (latestSeq.present) {
      map['latest_seq'] = Variable<int>(latestSeq.value);
    }
    if (latestId.present) {
      map['latest_id'] = Variable<String>(latestId.value);
    }
    if (latestLamport.present) {
      map['latest_lamport'] = Variable<int>(latestLamport.value);
    }
    if (revokedAfterSeq.present) {
      map['revoked_after_seq'] = Variable<int>(revokedAfterSeq.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<int>(purpose.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('feedId: $feedId, ')
          ..write('rootId: $rootId, ')
          ..write('latestSeq: $latestSeq, ')
          ..write('latestId: $latestId, ')
          ..write('latestLamport: $latestLamport, ')
          ..write('revokedAfterSeq: $revokedAfterSeq, ')
          ..write('purpose: $purpose, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hopsMeta = const VerificationMeta('hops');
  @override
  late final GeneratedColumn<int> hops = GeneratedColumn<int>(
    'hops',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    seq,
    rootId,
    lamport,
    ts,
    type,
    raw,
    body,
    hops,
    firstSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('hops')) {
      context.handle(
        _hopsMeta,
        hops.isAcceptableOrUnknown(data['hops']!, _hopsMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {feedId, seq},
  ];
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      hops: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hops'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String feedId;
  final int seq;
  final String rootId;
  final int lamport;
  final int ts;
  final String type;

  /// Canonical JSON of the signed event.
  final String raw;

  /// Canonical JSON of the body; null once erased by a tombstone.
  final String? body;

  /// Unsigned hop counter (0 = authored here). Cosmetic: postmarks only.
  final int hops;
  final int firstSeenAt;
  const EventRow({
    required this.id,
    required this.feedId,
    required this.seq,
    required this.rootId,
    required this.lamport,
    required this.ts,
    required this.type,
    required this.raw,
    this.body,
    required this.hops,
    required this.firstSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feed_id'] = Variable<String>(feedId);
    map['seq'] = Variable<int>(seq);
    map['root_id'] = Variable<String>(rootId);
    map['lamport'] = Variable<int>(lamport);
    map['ts'] = Variable<int>(ts);
    map['type'] = Variable<String>(type);
    map['raw'] = Variable<String>(raw);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['hops'] = Variable<int>(hops);
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      feedId: Value(feedId),
      seq: Value(seq),
      rootId: Value(rootId),
      lamport: Value(lamport),
      ts: Value(ts),
      type: Value(type),
      raw: Value(raw),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      hops: Value(hops),
      firstSeenAt: Value(firstSeenAt),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      feedId: serializer.fromJson<String>(json['feedId']),
      seq: serializer.fromJson<int>(json['seq']),
      rootId: serializer.fromJson<String>(json['rootId']),
      lamport: serializer.fromJson<int>(json['lamport']),
      ts: serializer.fromJson<int>(json['ts']),
      type: serializer.fromJson<String>(json['type']),
      raw: serializer.fromJson<String>(json['raw']),
      body: serializer.fromJson<String?>(json['body']),
      hops: serializer.fromJson<int>(json['hops']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feedId': serializer.toJson<String>(feedId),
      'seq': serializer.toJson<int>(seq),
      'rootId': serializer.toJson<String>(rootId),
      'lamport': serializer.toJson<int>(lamport),
      'ts': serializer.toJson<int>(ts),
      'type': serializer.toJson<String>(type),
      'raw': serializer.toJson<String>(raw),
      'body': serializer.toJson<String?>(body),
      'hops': serializer.toJson<int>(hops),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
    };
  }

  EventRow copyWith({
    String? id,
    String? feedId,
    int? seq,
    String? rootId,
    int? lamport,
    int? ts,
    String? type,
    String? raw,
    Value<String?> body = const Value.absent(),
    int? hops,
    int? firstSeenAt,
  }) => EventRow(
    id: id ?? this.id,
    feedId: feedId ?? this.feedId,
    seq: seq ?? this.seq,
    rootId: rootId ?? this.rootId,
    lamport: lamport ?? this.lamport,
    ts: ts ?? this.ts,
    type: type ?? this.type,
    raw: raw ?? this.raw,
    body: body.present ? body.value : this.body,
    hops: hops ?? this.hops,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      seq: data.seq.present ? data.seq.value : this.seq,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      ts: data.ts.present ? data.ts.value : this.ts,
      type: data.type.present ? data.type.value : this.type,
      raw: data.raw.present ? data.raw.value : this.raw,
      body: data.body.present ? data.body.value : this.body,
      hops: data.hops.present ? data.hops.value : this.hops,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('seq: $seq, ')
          ..write('rootId: $rootId, ')
          ..write('lamport: $lamport, ')
          ..write('ts: $ts, ')
          ..write('type: $type, ')
          ..write('raw: $raw, ')
          ..write('body: $body, ')
          ..write('hops: $hops, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feedId,
    seq,
    rootId,
    lamport,
    ts,
    type,
    raw,
    body,
    hops,
    firstSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.seq == this.seq &&
          other.rootId == this.rootId &&
          other.lamport == this.lamport &&
          other.ts == this.ts &&
          other.type == this.type &&
          other.raw == this.raw &&
          other.body == this.body &&
          other.hops == this.hops &&
          other.firstSeenAt == this.firstSeenAt);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> feedId;
  final Value<int> seq;
  final Value<String> rootId;
  final Value<int> lamport;
  final Value<int> ts;
  final Value<String> type;
  final Value<String> raw;
  final Value<String?> body;
  final Value<int> hops;
  final Value<int> firstSeenAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.seq = const Value.absent(),
    this.rootId = const Value.absent(),
    this.lamport = const Value.absent(),
    this.ts = const Value.absent(),
    this.type = const Value.absent(),
    this.raw = const Value.absent(),
    this.body = const Value.absent(),
    this.hops = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String feedId,
    required int seq,
    required String rootId,
    required int lamport,
    required int ts,
    required String type,
    required String raw,
    this.body = const Value.absent(),
    this.hops = const Value.absent(),
    required int firstSeenAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedId = Value(feedId),
       seq = Value(seq),
       rootId = Value(rootId),
       lamport = Value(lamport),
       ts = Value(ts),
       type = Value(type),
       raw = Value(raw),
       firstSeenAt = Value(firstSeenAt);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? feedId,
    Expression<int>? seq,
    Expression<String>? rootId,
    Expression<int>? lamport,
    Expression<int>? ts,
    Expression<String>? type,
    Expression<String>? raw,
    Expression<String>? body,
    Expression<int>? hops,
    Expression<int>? firstSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (seq != null) 'seq': seq,
      if (rootId != null) 'root_id': rootId,
      if (lamport != null) 'lamport': lamport,
      if (ts != null) 'ts': ts,
      if (type != null) 'type': type,
      if (raw != null) 'raw': raw,
      if (body != null) 'body': body,
      if (hops != null) 'hops': hops,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? feedId,
    Value<int>? seq,
    Value<String>? rootId,
    Value<int>? lamport,
    Value<int>? ts,
    Value<String>? type,
    Value<String>? raw,
    Value<String?>? body,
    Value<int>? hops,
    Value<int>? firstSeenAt,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      seq: seq ?? this.seq,
      rootId: rootId ?? this.rootId,
      lamport: lamport ?? this.lamport,
      ts: ts ?? this.ts,
      type: type ?? this.type,
      raw: raw ?? this.raw,
      body: body ?? this.body,
      hops: hops ?? this.hops,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (hops.present) {
      map['hops'] = Variable<int>(hops.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('seq: $seq, ')
          ..write('rootId: $rootId, ')
          ..write('lamport: $lamport, ')
          ..write('ts: $ts, ')
          ..write('type: $type, ')
          ..write('raw: $raw, ')
          ..write('body: $body, ')
          ..write('hops: $hops, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  @override
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dmKeyMeta = const VerificationMeta('dmKey');
  @override
  late final GeneratedColumn<String> dmKey = GeneratedColumn<String>(
    'dm_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handleSkelMeta = const VerificationMeta(
    'handleSkel',
  );
  @override
  late final GeneratedColumn<String> handleSkel = GeneratedColumn<String>(
    'handle_skel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameSkelMeta = const VerificationMeta(
    'nameSkel',
  );
  @override
  late final GeneratedColumn<String> nameSkel = GeneratedColumn<String>(
    'name_skel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    rootId,
    name,
    handle,
    bio,
    dmKey,
    avatar,
    lamport,
    eventId,
    handleSkel,
    nameSkel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('dm_key')) {
      context.handle(
        _dmKeyMeta,
        dmKey.isAcceptableOrUnknown(data['dm_key']!, _dmKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dmKeyMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('handle_skel')) {
      context.handle(
        _handleSkelMeta,
        handleSkel.isAcceptableOrUnknown(data['handle_skel']!, _handleSkelMeta),
      );
    }
    if (data.containsKey('name_skel')) {
      context.handle(
        _nameSkelMeta,
        nameSkel.isAcceptableOrUnknown(data['name_skel']!, _nameSkelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      )!,
      dmKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dm_key'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      handleSkel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle_skel'],
      )!,
      nameSkel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_skel'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String rootId;
  final String name;
  final String handle;
  final String bio;
  final String dmKey;
  final String? avatar;
  final int lamport;
  final String eventId;

  /// Lookalike skeletons of handle and name (v4, indexed).
  final String handleSkel;
  final String nameSkel;
  const ProfileRow({
    required this.rootId,
    required this.name,
    required this.handle,
    required this.bio,
    required this.dmKey,
    this.avatar,
    required this.lamport,
    required this.eventId,
    required this.handleSkel,
    required this.nameSkel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['name'] = Variable<String>(name);
    map['handle'] = Variable<String>(handle);
    map['bio'] = Variable<String>(bio);
    map['dm_key'] = Variable<String>(dmKey);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['lamport'] = Variable<int>(lamport);
    map['event_id'] = Variable<String>(eventId);
    map['handle_skel'] = Variable<String>(handleSkel);
    map['name_skel'] = Variable<String>(nameSkel);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      rootId: Value(rootId),
      name: Value(name),
      handle: Value(handle),
      bio: Value(bio),
      dmKey: Value(dmKey),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      lamport: Value(lamport),
      eventId: Value(eventId),
      handleSkel: Value(handleSkel),
      nameSkel: Value(nameSkel),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      name: serializer.fromJson<String>(json['name']),
      handle: serializer.fromJson<String>(json['handle']),
      bio: serializer.fromJson<String>(json['bio']),
      dmKey: serializer.fromJson<String>(json['dmKey']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      lamport: serializer.fromJson<int>(json['lamport']),
      eventId: serializer.fromJson<String>(json['eventId']),
      handleSkel: serializer.fromJson<String>(json['handleSkel']),
      nameSkel: serializer.fromJson<String>(json['nameSkel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'name': serializer.toJson<String>(name),
      'handle': serializer.toJson<String>(handle),
      'bio': serializer.toJson<String>(bio),
      'dmKey': serializer.toJson<String>(dmKey),
      'avatar': serializer.toJson<String?>(avatar),
      'lamport': serializer.toJson<int>(lamport),
      'eventId': serializer.toJson<String>(eventId),
      'handleSkel': serializer.toJson<String>(handleSkel),
      'nameSkel': serializer.toJson<String>(nameSkel),
    };
  }

  ProfileRow copyWith({
    String? rootId,
    String? name,
    String? handle,
    String? bio,
    String? dmKey,
    Value<String?> avatar = const Value.absent(),
    int? lamport,
    String? eventId,
    String? handleSkel,
    String? nameSkel,
  }) => ProfileRow(
    rootId: rootId ?? this.rootId,
    name: name ?? this.name,
    handle: handle ?? this.handle,
    bio: bio ?? this.bio,
    dmKey: dmKey ?? this.dmKey,
    avatar: avatar.present ? avatar.value : this.avatar,
    lamport: lamport ?? this.lamport,
    eventId: eventId ?? this.eventId,
    handleSkel: handleSkel ?? this.handleSkel,
    nameSkel: nameSkel ?? this.nameSkel,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      name: data.name.present ? data.name.value : this.name,
      handle: data.handle.present ? data.handle.value : this.handle,
      bio: data.bio.present ? data.bio.value : this.bio,
      dmKey: data.dmKey.present ? data.dmKey.value : this.dmKey,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      handleSkel: data.handleSkel.present
          ? data.handleSkel.value
          : this.handleSkel,
      nameSkel: data.nameSkel.present ? data.nameSkel.value : this.nameSkel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('rootId: $rootId, ')
          ..write('name: $name, ')
          ..write('handle: $handle, ')
          ..write('bio: $bio, ')
          ..write('dmKey: $dmKey, ')
          ..write('avatar: $avatar, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId, ')
          ..write('handleSkel: $handleSkel, ')
          ..write('nameSkel: $nameSkel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rootId,
    name,
    handle,
    bio,
    dmKey,
    avatar,
    lamport,
    eventId,
    handleSkel,
    nameSkel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.rootId == this.rootId &&
          other.name == this.name &&
          other.handle == this.handle &&
          other.bio == this.bio &&
          other.dmKey == this.dmKey &&
          other.avatar == this.avatar &&
          other.lamport == this.lamport &&
          other.eventId == this.eventId &&
          other.handleSkel == this.handleSkel &&
          other.nameSkel == this.nameSkel);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> rootId;
  final Value<String> name;
  final Value<String> handle;
  final Value<String> bio;
  final Value<String> dmKey;
  final Value<String?> avatar;
  final Value<int> lamport;
  final Value<String> eventId;
  final Value<String> handleSkel;
  final Value<String> nameSkel;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.rootId = const Value.absent(),
    this.name = const Value.absent(),
    this.handle = const Value.absent(),
    this.bio = const Value.absent(),
    this.dmKey = const Value.absent(),
    this.avatar = const Value.absent(),
    this.lamport = const Value.absent(),
    this.eventId = const Value.absent(),
    this.handleSkel = const Value.absent(),
    this.nameSkel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String rootId,
    required String name,
    required String handle,
    this.bio = const Value.absent(),
    required String dmKey,
    this.avatar = const Value.absent(),
    required int lamport,
    required String eventId,
    this.handleSkel = const Value.absent(),
    this.nameSkel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       name = Value(name),
       handle = Value(handle),
       dmKey = Value(dmKey),
       lamport = Value(lamport),
       eventId = Value(eventId);
  static Insertable<ProfileRow> custom({
    Expression<String>? rootId,
    Expression<String>? name,
    Expression<String>? handle,
    Expression<String>? bio,
    Expression<String>? dmKey,
    Expression<String>? avatar,
    Expression<int>? lamport,
    Expression<String>? eventId,
    Expression<String>? handleSkel,
    Expression<String>? nameSkel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (name != null) 'name': name,
      if (handle != null) 'handle': handle,
      if (bio != null) 'bio': bio,
      if (dmKey != null) 'dm_key': dmKey,
      if (avatar != null) 'avatar': avatar,
      if (lamport != null) 'lamport': lamport,
      if (eventId != null) 'event_id': eventId,
      if (handleSkel != null) 'handle_skel': handleSkel,
      if (nameSkel != null) 'name_skel': nameSkel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? rootId,
    Value<String>? name,
    Value<String>? handle,
    Value<String>? bio,
    Value<String>? dmKey,
    Value<String?>? avatar,
    Value<int>? lamport,
    Value<String>? eventId,
    Value<String>? handleSkel,
    Value<String>? nameSkel,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      rootId: rootId ?? this.rootId,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      dmKey: dmKey ?? this.dmKey,
      avatar: avatar ?? this.avatar,
      lamport: lamport ?? this.lamport,
      eventId: eventId ?? this.eventId,
      handleSkel: handleSkel ?? this.handleSkel,
      nameSkel: nameSkel ?? this.nameSkel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (dmKey.present) {
      map['dm_key'] = Variable<String>(dmKey.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (handleSkel.present) {
      map['handle_skel'] = Variable<String>(handleSkel.value);
    }
    if (nameSkel.present) {
      map['name_skel'] = Variable<String>(nameSkel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('rootId: $rootId, ')
          ..write('name: $name, ')
          ..write('handle: $handle, ')
          ..write('bio: $bio, ')
          ..write('dmKey: $dmKey, ')
          ..write('avatar: $avatar, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId, ')
          ..write('handleSkel: $handleSkel, ')
          ..write('nameSkel: $nameSkel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, PostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaMeta = const VerificationMeta('media');
  @override
  late final GeneratedColumn<String> media = GeneratedColumn<String>(
    'media',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editLamportMeta = const VerificationMeta(
    'editLamport',
  );
  @override
  late final GeneratedColumn<int> editLamport = GeneratedColumn<int>(
    'edit_lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _editIdMeta = const VerificationMeta('editId');
  @override
  late final GeneratedColumn<String> editId = GeneratedColumn<String>(
    'edit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hopsMeta = const VerificationMeta('hops');
  @override
  late final GeneratedColumn<int> hops = GeneratedColumn<int>(
    'hops',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<int> firstSeenAt = GeneratedColumn<int>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rootId,
    feedId,
    body,
    media,
    ts,
    lamport,
    editLamport,
    editId,
    hops,
    firstSeenAt,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('media')) {
      context.handle(
        _mediaMeta,
        media.isAcceptableOrUnknown(data['media']!, _mediaMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('edit_lamport')) {
      context.handle(
        _editLamportMeta,
        editLamport.isAcceptableOrUnknown(
          data['edit_lamport']!,
          _editLamportMeta,
        ),
      );
    }
    if (data.containsKey('edit_id')) {
      context.handle(
        _editIdMeta,
        editId.isAcceptableOrUnknown(data['edit_id']!, _editIdMeta),
      );
    }
    if (data.containsKey('hops')) {
      context.handle(
        _hopsMeta,
        hops.isAcceptableOrUnknown(data['hops']!, _hopsMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      media: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      editLamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edit_lamport'],
      )!,
      editId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edit_id'],
      ),
      hops: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hops'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class PostRow extends DataClass implements Insertable<PostRow> {
  final String id;
  final String rootId;
  final String feedId;
  final String body;
  final String media;
  final int ts;
  final int lamport;

  /// Lamport of the winning `post.edit`, 0 if never edited.
  final int editLamport;
  final String? editId;
  final int hops;
  final int firstSeenAt;
  final bool deleted;
  const PostRow({
    required this.id,
    required this.rootId,
    required this.feedId,
    required this.body,
    required this.media,
    required this.ts,
    required this.lamport,
    required this.editLamport,
    this.editId,
    required this.hops,
    required this.firstSeenAt,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['root_id'] = Variable<String>(rootId);
    map['feed_id'] = Variable<String>(feedId);
    map['body'] = Variable<String>(body);
    map['media'] = Variable<String>(media);
    map['ts'] = Variable<int>(ts);
    map['lamport'] = Variable<int>(lamport);
    map['edit_lamport'] = Variable<int>(editLamport);
    if (!nullToAbsent || editId != null) {
      map['edit_id'] = Variable<String>(editId);
    }
    map['hops'] = Variable<int>(hops);
    map['first_seen_at'] = Variable<int>(firstSeenAt);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      rootId: Value(rootId),
      feedId: Value(feedId),
      body: Value(body),
      media: Value(media),
      ts: Value(ts),
      lamport: Value(lamport),
      editLamport: Value(editLamport),
      editId: editId == null && nullToAbsent
          ? const Value.absent()
          : Value(editId),
      hops: Value(hops),
      firstSeenAt: Value(firstSeenAt),
      deleted: Value(deleted),
    );
  }

  factory PostRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostRow(
      id: serializer.fromJson<String>(json['id']),
      rootId: serializer.fromJson<String>(json['rootId']),
      feedId: serializer.fromJson<String>(json['feedId']),
      body: serializer.fromJson<String>(json['body']),
      media: serializer.fromJson<String>(json['media']),
      ts: serializer.fromJson<int>(json['ts']),
      lamport: serializer.fromJson<int>(json['lamport']),
      editLamport: serializer.fromJson<int>(json['editLamport']),
      editId: serializer.fromJson<String?>(json['editId']),
      hops: serializer.fromJson<int>(json['hops']),
      firstSeenAt: serializer.fromJson<int>(json['firstSeenAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rootId': serializer.toJson<String>(rootId),
      'feedId': serializer.toJson<String>(feedId),
      'body': serializer.toJson<String>(body),
      'media': serializer.toJson<String>(media),
      'ts': serializer.toJson<int>(ts),
      'lamport': serializer.toJson<int>(lamport),
      'editLamport': serializer.toJson<int>(editLamport),
      'editId': serializer.toJson<String?>(editId),
      'hops': serializer.toJson<int>(hops),
      'firstSeenAt': serializer.toJson<int>(firstSeenAt),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  PostRow copyWith({
    String? id,
    String? rootId,
    String? feedId,
    String? body,
    String? media,
    int? ts,
    int? lamport,
    int? editLamport,
    Value<String?> editId = const Value.absent(),
    int? hops,
    int? firstSeenAt,
    bool? deleted,
  }) => PostRow(
    id: id ?? this.id,
    rootId: rootId ?? this.rootId,
    feedId: feedId ?? this.feedId,
    body: body ?? this.body,
    media: media ?? this.media,
    ts: ts ?? this.ts,
    lamport: lamport ?? this.lamport,
    editLamport: editLamport ?? this.editLamport,
    editId: editId.present ? editId.value : this.editId,
    hops: hops ?? this.hops,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    deleted: deleted ?? this.deleted,
  );
  PostRow copyWithCompanion(PostsCompanion data) {
    return PostRow(
      id: data.id.present ? data.id.value : this.id,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      body: data.body.present ? data.body.value : this.body,
      media: data.media.present ? data.media.value : this.media,
      ts: data.ts.present ? data.ts.value : this.ts,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      editLamport: data.editLamport.present
          ? data.editLamport.value
          : this.editLamport,
      editId: data.editId.present ? data.editId.value : this.editId,
      hops: data.hops.present ? data.hops.value : this.hops,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostRow(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('feedId: $feedId, ')
          ..write('body: $body, ')
          ..write('media: $media, ')
          ..write('ts: $ts, ')
          ..write('lamport: $lamport, ')
          ..write('editLamport: $editLamport, ')
          ..write('editId: $editId, ')
          ..write('hops: $hops, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rootId,
    feedId,
    body,
    media,
    ts,
    lamport,
    editLamport,
    editId,
    hops,
    firstSeenAt,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostRow &&
          other.id == this.id &&
          other.rootId == this.rootId &&
          other.feedId == this.feedId &&
          other.body == this.body &&
          other.media == this.media &&
          other.ts == this.ts &&
          other.lamport == this.lamport &&
          other.editLamport == this.editLamport &&
          other.editId == this.editId &&
          other.hops == this.hops &&
          other.firstSeenAt == this.firstSeenAt &&
          other.deleted == this.deleted);
}

class PostsCompanion extends UpdateCompanion<PostRow> {
  final Value<String> id;
  final Value<String> rootId;
  final Value<String> feedId;
  final Value<String> body;
  final Value<String> media;
  final Value<int> ts;
  final Value<int> lamport;
  final Value<int> editLamport;
  final Value<String?> editId;
  final Value<int> hops;
  final Value<int> firstSeenAt;
  final Value<bool> deleted;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.rootId = const Value.absent(),
    this.feedId = const Value.absent(),
    this.body = const Value.absent(),
    this.media = const Value.absent(),
    this.ts = const Value.absent(),
    this.lamport = const Value.absent(),
    this.editLamport = const Value.absent(),
    this.editId = const Value.absent(),
    this.hops = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    required String rootId,
    required String feedId,
    required String body,
    this.media = const Value.absent(),
    required int ts,
    required int lamport,
    this.editLamport = const Value.absent(),
    this.editId = const Value.absent(),
    this.hops = const Value.absent(),
    required int firstSeenAt,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rootId = Value(rootId),
       feedId = Value(feedId),
       body = Value(body),
       ts = Value(ts),
       lamport = Value(lamport),
       firstSeenAt = Value(firstSeenAt);
  static Insertable<PostRow> custom({
    Expression<String>? id,
    Expression<String>? rootId,
    Expression<String>? feedId,
    Expression<String>? body,
    Expression<String>? media,
    Expression<int>? ts,
    Expression<int>? lamport,
    Expression<int>? editLamport,
    Expression<String>? editId,
    Expression<int>? hops,
    Expression<int>? firstSeenAt,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rootId != null) 'root_id': rootId,
      if (feedId != null) 'feed_id': feedId,
      if (body != null) 'body': body,
      if (media != null) 'media': media,
      if (ts != null) 'ts': ts,
      if (lamport != null) 'lamport': lamport,
      if (editLamport != null) 'edit_lamport': editLamport,
      if (editId != null) 'edit_id': editId,
      if (hops != null) 'hops': hops,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String>? rootId,
    Value<String>? feedId,
    Value<String>? body,
    Value<String>? media,
    Value<int>? ts,
    Value<int>? lamport,
    Value<int>? editLamport,
    Value<String?>? editId,
    Value<int>? hops,
    Value<int>? firstSeenAt,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      rootId: rootId ?? this.rootId,
      feedId: feedId ?? this.feedId,
      body: body ?? this.body,
      media: media ?? this.media,
      ts: ts ?? this.ts,
      lamport: lamport ?? this.lamport,
      editLamport: editLamport ?? this.editLamport,
      editId: editId ?? this.editId,
      hops: hops ?? this.hops,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (media.present) {
      map['media'] = Variable<String>(media.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (editLamport.present) {
      map['edit_lamport'] = Variable<int>(editLamport.value);
    }
    if (editId.present) {
      map['edit_id'] = Variable<String>(editId.value);
    }
    if (hops.present) {
      map['hops'] = Variable<int>(hops.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<int>(firstSeenAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('rootId: $rootId, ')
          ..write('feedId: $feedId, ')
          ..write('body: $body, ')
          ..write('media: $media, ')
          ..write('ts: $ts, ')
          ..write('lamport: $lamport, ')
          ..write('editLamport: $editLamport, ')
          ..write('editId: $editId, ')
          ..write('hops: $hops, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReactionsTable extends Reactions
    with TableInfo<$ReactionsTable, ReactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stickerMeta = const VerificationMeta(
    'sticker',
  );
  @override
  late final GeneratedColumn<String> sticker = GeneratedColumn<String>(
    'sticker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotMeta = const VerificationMeta('rot');
  @override
  late final GeneratedColumn<int> rot = GeneratedColumn<int>(
    'rot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rootId,
    target,
    sticker,
    x,
    y,
    rot,
    lamport,
    eventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('sticker')) {
      context.handle(
        _stickerMeta,
        sticker.isAcceptableOrUnknown(data['sticker']!, _stickerMeta),
      );
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('rot')) {
      context.handle(
        _rotMeta,
        rot.isAcceptableOrUnknown(data['rot']!, _rotMeta),
      );
    } else if (isInserting) {
      context.missing(_rotMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId, target};
  @override
  ReactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      sticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sticker'],
      ),
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y'],
      )!,
      rot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rot'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
    );
  }

  @override
  $ReactionsTable createAlias(String alias) {
    return $ReactionsTable(attachedDatabase, alias);
  }
}

class ReactionRow extends DataClass implements Insertable<ReactionRow> {
  final String rootId;
  final String target;
  final String? sticker;
  final int x;
  final int y;
  final int rot;
  final int lamport;
  final String eventId;
  const ReactionRow({
    required this.rootId,
    required this.target,
    this.sticker,
    required this.x,
    required this.y,
    required this.rot,
    required this.lamport,
    required this.eventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['target'] = Variable<String>(target);
    if (!nullToAbsent || sticker != null) {
      map['sticker'] = Variable<String>(sticker);
    }
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    map['rot'] = Variable<int>(rot);
    map['lamport'] = Variable<int>(lamport);
    map['event_id'] = Variable<String>(eventId);
    return map;
  }

  ReactionsCompanion toCompanion(bool nullToAbsent) {
    return ReactionsCompanion(
      rootId: Value(rootId),
      target: Value(target),
      sticker: sticker == null && nullToAbsent
          ? const Value.absent()
          : Value(sticker),
      x: Value(x),
      y: Value(y),
      rot: Value(rot),
      lamport: Value(lamport),
      eventId: Value(eventId),
    );
  }

  factory ReactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      target: serializer.fromJson<String>(json['target']),
      sticker: serializer.fromJson<String?>(json['sticker']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
      rot: serializer.fromJson<int>(json['rot']),
      lamport: serializer.fromJson<int>(json['lamport']),
      eventId: serializer.fromJson<String>(json['eventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'target': serializer.toJson<String>(target),
      'sticker': serializer.toJson<String?>(sticker),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
      'rot': serializer.toJson<int>(rot),
      'lamport': serializer.toJson<int>(lamport),
      'eventId': serializer.toJson<String>(eventId),
    };
  }

  ReactionRow copyWith({
    String? rootId,
    String? target,
    Value<String?> sticker = const Value.absent(),
    int? x,
    int? y,
    int? rot,
    int? lamport,
    String? eventId,
  }) => ReactionRow(
    rootId: rootId ?? this.rootId,
    target: target ?? this.target,
    sticker: sticker.present ? sticker.value : this.sticker,
    x: x ?? this.x,
    y: y ?? this.y,
    rot: rot ?? this.rot,
    lamport: lamport ?? this.lamport,
    eventId: eventId ?? this.eventId,
  );
  ReactionRow copyWithCompanion(ReactionsCompanion data) {
    return ReactionRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      target: data.target.present ? data.target.value : this.target,
      sticker: data.sticker.present ? data.sticker.value : this.sticker,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      rot: data.rot.present ? data.rot.value : this.rot,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionRow(')
          ..write('rootId: $rootId, ')
          ..write('target: $target, ')
          ..write('sticker: $sticker, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rot: $rot, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rootId, target, sticker, x, y, rot, lamport, eventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionRow &&
          other.rootId == this.rootId &&
          other.target == this.target &&
          other.sticker == this.sticker &&
          other.x == this.x &&
          other.y == this.y &&
          other.rot == this.rot &&
          other.lamport == this.lamport &&
          other.eventId == this.eventId);
}

class ReactionsCompanion extends UpdateCompanion<ReactionRow> {
  final Value<String> rootId;
  final Value<String> target;
  final Value<String?> sticker;
  final Value<int> x;
  final Value<int> y;
  final Value<int> rot;
  final Value<int> lamport;
  final Value<String> eventId;
  final Value<int> rowid;
  const ReactionsCompanion({
    this.rootId = const Value.absent(),
    this.target = const Value.absent(),
    this.sticker = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rot = const Value.absent(),
    this.lamport = const Value.absent(),
    this.eventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionsCompanion.insert({
    required String rootId,
    required String target,
    this.sticker = const Value.absent(),
    required int x,
    required int y,
    required int rot,
    required int lamport,
    required String eventId,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       target = Value(target),
       x = Value(x),
       y = Value(y),
       rot = Value(rot),
       lamport = Value(lamport),
       eventId = Value(eventId);
  static Insertable<ReactionRow> custom({
    Expression<String>? rootId,
    Expression<String>? target,
    Expression<String>? sticker,
    Expression<int>? x,
    Expression<int>? y,
    Expression<int>? rot,
    Expression<int>? lamport,
    Expression<String>? eventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (target != null) 'target': target,
      if (sticker != null) 'sticker': sticker,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rot != null) 'rot': rot,
      if (lamport != null) 'lamport': lamport,
      if (eventId != null) 'event_id': eventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionsCompanion copyWith({
    Value<String>? rootId,
    Value<String>? target,
    Value<String?>? sticker,
    Value<int>? x,
    Value<int>? y,
    Value<int>? rot,
    Value<int>? lamport,
    Value<String>? eventId,
    Value<int>? rowid,
  }) {
    return ReactionsCompanion(
      rootId: rootId ?? this.rootId,
      target: target ?? this.target,
      sticker: sticker ?? this.sticker,
      x: x ?? this.x,
      y: y ?? this.y,
      rot: rot ?? this.rot,
      lamport: lamport ?? this.lamport,
      eventId: eventId ?? this.eventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (sticker.present) {
      map['sticker'] = Variable<String>(sticker.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (rot.present) {
      map['rot'] = Variable<int>(rot.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionsCompanion(')
          ..write('rootId: $rootId, ')
          ..write('target: $target, ')
          ..write('sticker: $sticker, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rot: $rot, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTable extends Comments
    with TableInfo<$CommentsTable, CommentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentMeta = const VerificationMeta('parent');
  @override
  late final GeneratedColumn<String> parent = GeneratedColumn<String>(
    'parent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    target,
    rootId,
    body,
    parent,
    ts,
    lamport,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('parent')) {
      context.handle(
        _parentMeta,
        parent.isAcceptableOrUnknown(data['parent']!, _parentMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      parent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent'],
      ),
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $CommentsTable createAlias(String alias) {
    return $CommentsTable(attachedDatabase, alias);
  }
}

class CommentRow extends DataClass implements Insertable<CommentRow> {
  final String id;
  final String target;
  final String rootId;
  final String body;
  final String? parent;
  final int ts;
  final int lamport;
  final bool deleted;
  const CommentRow({
    required this.id,
    required this.target,
    required this.rootId,
    required this.body,
    this.parent,
    required this.ts,
    required this.lamport,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target'] = Variable<String>(target);
    map['root_id'] = Variable<String>(rootId);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || parent != null) {
      map['parent'] = Variable<String>(parent);
    }
    map['ts'] = Variable<int>(ts);
    map['lamport'] = Variable<int>(lamport);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  CommentsCompanion toCompanion(bool nullToAbsent) {
    return CommentsCompanion(
      id: Value(id),
      target: Value(target),
      rootId: Value(rootId),
      body: Value(body),
      parent: parent == null && nullToAbsent
          ? const Value.absent()
          : Value(parent),
      ts: Value(ts),
      lamport: Value(lamport),
      deleted: Value(deleted),
    );
  }

  factory CommentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentRow(
      id: serializer.fromJson<String>(json['id']),
      target: serializer.fromJson<String>(json['target']),
      rootId: serializer.fromJson<String>(json['rootId']),
      body: serializer.fromJson<String>(json['body']),
      parent: serializer.fromJson<String?>(json['parent']),
      ts: serializer.fromJson<int>(json['ts']),
      lamport: serializer.fromJson<int>(json['lamport']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'target': serializer.toJson<String>(target),
      'rootId': serializer.toJson<String>(rootId),
      'body': serializer.toJson<String>(body),
      'parent': serializer.toJson<String?>(parent),
      'ts': serializer.toJson<int>(ts),
      'lamport': serializer.toJson<int>(lamport),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  CommentRow copyWith({
    String? id,
    String? target,
    String? rootId,
    String? body,
    Value<String?> parent = const Value.absent(),
    int? ts,
    int? lamport,
    bool? deleted,
  }) => CommentRow(
    id: id ?? this.id,
    target: target ?? this.target,
    rootId: rootId ?? this.rootId,
    body: body ?? this.body,
    parent: parent.present ? parent.value : this.parent,
    ts: ts ?? this.ts,
    lamport: lamport ?? this.lamport,
    deleted: deleted ?? this.deleted,
  );
  CommentRow copyWithCompanion(CommentsCompanion data) {
    return CommentRow(
      id: data.id.present ? data.id.value : this.id,
      target: data.target.present ? data.target.value : this.target,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      body: data.body.present ? data.body.value : this.body,
      parent: data.parent.present ? data.parent.value : this.parent,
      ts: data.ts.present ? data.ts.value : this.ts,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentRow(')
          ..write('id: $id, ')
          ..write('target: $target, ')
          ..write('rootId: $rootId, ')
          ..write('body: $body, ')
          ..write('parent: $parent, ')
          ..write('ts: $ts, ')
          ..write('lamport: $lamport, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, target, rootId, body, parent, ts, lamport, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentRow &&
          other.id == this.id &&
          other.target == this.target &&
          other.rootId == this.rootId &&
          other.body == this.body &&
          other.parent == this.parent &&
          other.ts == this.ts &&
          other.lamport == this.lamport &&
          other.deleted == this.deleted);
}

class CommentsCompanion extends UpdateCompanion<CommentRow> {
  final Value<String> id;
  final Value<String> target;
  final Value<String> rootId;
  final Value<String> body;
  final Value<String?> parent;
  final Value<int> ts;
  final Value<int> lamport;
  final Value<bool> deleted;
  final Value<int> rowid;
  const CommentsCompanion({
    this.id = const Value.absent(),
    this.target = const Value.absent(),
    this.rootId = const Value.absent(),
    this.body = const Value.absent(),
    this.parent = const Value.absent(),
    this.ts = const Value.absent(),
    this.lamport = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsCompanion.insert({
    required String id,
    required String target,
    required String rootId,
    required String body,
    this.parent = const Value.absent(),
    required int ts,
    required int lamport,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       target = Value(target),
       rootId = Value(rootId),
       body = Value(body),
       ts = Value(ts),
       lamport = Value(lamport);
  static Insertable<CommentRow> custom({
    Expression<String>? id,
    Expression<String>? target,
    Expression<String>? rootId,
    Expression<String>? body,
    Expression<String>? parent,
    Expression<int>? ts,
    Expression<int>? lamport,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (target != null) 'target': target,
      if (rootId != null) 'root_id': rootId,
      if (body != null) 'body': body,
      if (parent != null) 'parent': parent,
      if (ts != null) 'ts': ts,
      if (lamport != null) 'lamport': lamport,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? target,
    Value<String>? rootId,
    Value<String>? body,
    Value<String?>? parent,
    Value<int>? ts,
    Value<int>? lamport,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return CommentsCompanion(
      id: id ?? this.id,
      target: target ?? this.target,
      rootId: rootId ?? this.rootId,
      body: body ?? this.body,
      parent: parent ?? this.parent,
      ts: ts ?? this.ts,
      lamport: lamport ?? this.lamport,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (parent.present) {
      map['parent'] = Variable<String>(parent.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsCompanion(')
          ..write('id: $id, ')
          ..write('target: $target, ')
          ..write('rootId: $rootId, ')
          ..write('body: $body, ')
          ..write('parent: $parent, ')
          ..write('ts: $ts, ')
          ..write('lamport: $lamport, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FollowsTable extends Follows with TableInfo<$FollowsTable, FollowRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOnMeta = const VerificationMeta('isOn');
  @override
  late final GeneratedColumn<bool> isOn = GeneratedColumn<bool>(
    'is_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_on" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rootId,
    target,
    isOn,
    lamport,
    eventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows';
  @override
  VerificationContext validateIntegrity(
    Insertable<FollowRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('is_on')) {
      context.handle(
        _isOnMeta,
        isOn.isAcceptableOrUnknown(data['is_on']!, _isOnMeta),
      );
    } else if (isInserting) {
      context.missing(_isOnMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId, target};
  @override
  FollowRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      isOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_on'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
    );
  }

  @override
  $FollowsTable createAlias(String alias) {
    return $FollowsTable(attachedDatabase, alias);
  }
}

class FollowRow extends DataClass implements Insertable<FollowRow> {
  final String rootId;
  final String target;
  final bool isOn;
  final int lamport;
  final String eventId;
  const FollowRow({
    required this.rootId,
    required this.target,
    required this.isOn,
    required this.lamport,
    required this.eventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['target'] = Variable<String>(target);
    map['is_on'] = Variable<bool>(isOn);
    map['lamport'] = Variable<int>(lamport);
    map['event_id'] = Variable<String>(eventId);
    return map;
  }

  FollowsCompanion toCompanion(bool nullToAbsent) {
    return FollowsCompanion(
      rootId: Value(rootId),
      target: Value(target),
      isOn: Value(isOn),
      lamport: Value(lamport),
      eventId: Value(eventId),
    );
  }

  factory FollowRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      target: serializer.fromJson<String>(json['target']),
      isOn: serializer.fromJson<bool>(json['isOn']),
      lamport: serializer.fromJson<int>(json['lamport']),
      eventId: serializer.fromJson<String>(json['eventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'target': serializer.toJson<String>(target),
      'isOn': serializer.toJson<bool>(isOn),
      'lamport': serializer.toJson<int>(lamport),
      'eventId': serializer.toJson<String>(eventId),
    };
  }

  FollowRow copyWith({
    String? rootId,
    String? target,
    bool? isOn,
    int? lamport,
    String? eventId,
  }) => FollowRow(
    rootId: rootId ?? this.rootId,
    target: target ?? this.target,
    isOn: isOn ?? this.isOn,
    lamport: lamport ?? this.lamport,
    eventId: eventId ?? this.eventId,
  );
  FollowRow copyWithCompanion(FollowsCompanion data) {
    return FollowRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      target: data.target.present ? data.target.value : this.target,
      isOn: data.isOn.present ? data.isOn.value : this.isOn,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowRow(')
          ..write('rootId: $rootId, ')
          ..write('target: $target, ')
          ..write('isOn: $isOn, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, target, isOn, lamport, eventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowRow &&
          other.rootId == this.rootId &&
          other.target == this.target &&
          other.isOn == this.isOn &&
          other.lamport == this.lamport &&
          other.eventId == this.eventId);
}

class FollowsCompanion extends UpdateCompanion<FollowRow> {
  final Value<String> rootId;
  final Value<String> target;
  final Value<bool> isOn;
  final Value<int> lamport;
  final Value<String> eventId;
  final Value<int> rowid;
  const FollowsCompanion({
    this.rootId = const Value.absent(),
    this.target = const Value.absent(),
    this.isOn = const Value.absent(),
    this.lamport = const Value.absent(),
    this.eventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FollowsCompanion.insert({
    required String rootId,
    required String target,
    required bool isOn,
    required int lamport,
    required String eventId,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       target = Value(target),
       isOn = Value(isOn),
       lamport = Value(lamport),
       eventId = Value(eventId);
  static Insertable<FollowRow> custom({
    Expression<String>? rootId,
    Expression<String>? target,
    Expression<bool>? isOn,
    Expression<int>? lamport,
    Expression<String>? eventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (target != null) 'target': target,
      if (isOn != null) 'is_on': isOn,
      if (lamport != null) 'lamport': lamport,
      if (eventId != null) 'event_id': eventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FollowsCompanion copyWith({
    Value<String>? rootId,
    Value<String>? target,
    Value<bool>? isOn,
    Value<int>? lamport,
    Value<String>? eventId,
    Value<int>? rowid,
  }) {
    return FollowsCompanion(
      rootId: rootId ?? this.rootId,
      target: target ?? this.target,
      isOn: isOn ?? this.isOn,
      lamport: lamport ?? this.lamport,
      eventId: eventId ?? this.eventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (isOn.present) {
      map['is_on'] = Variable<bool>(isOn.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowsCompanion(')
          ..write('rootId: $rootId, ')
          ..write('target: $target, ')
          ..write('isOn: $isOn, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TombstonesTable extends Tombstones
    with TableInfo<$TombstonesTable, TombstoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byRootMeta = const VerificationMeta('byRoot');
  @override
  late final GeneratedColumn<String> byRoot = GeneratedColumn<String>(
    'by_root',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [target, byRoot, lamport, eventId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<TombstoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('by_root')) {
      context.handle(
        _byRootMeta,
        byRoot.isAcceptableOrUnknown(data['by_root']!, _byRootMeta),
      );
    } else if (isInserting) {
      context.missing(_byRootMeta);
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {target};
  @override
  TombstoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TombstoneRow(
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      byRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by_root'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
    );
  }

  @override
  $TombstonesTable createAlias(String alias) {
    return $TombstonesTable(attachedDatabase, alias);
  }
}

class TombstoneRow extends DataClass implements Insertable<TombstoneRow> {
  final String target;
  final String byRoot;
  final int lamport;
  final String eventId;
  const TombstoneRow({
    required this.target,
    required this.byRoot,
    required this.lamport,
    required this.eventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target'] = Variable<String>(target);
    map['by_root'] = Variable<String>(byRoot);
    map['lamport'] = Variable<int>(lamport);
    map['event_id'] = Variable<String>(eventId);
    return map;
  }

  TombstonesCompanion toCompanion(bool nullToAbsent) {
    return TombstonesCompanion(
      target: Value(target),
      byRoot: Value(byRoot),
      lamport: Value(lamport),
      eventId: Value(eventId),
    );
  }

  factory TombstoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TombstoneRow(
      target: serializer.fromJson<String>(json['target']),
      byRoot: serializer.fromJson<String>(json['byRoot']),
      lamport: serializer.fromJson<int>(json['lamport']),
      eventId: serializer.fromJson<String>(json['eventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'target': serializer.toJson<String>(target),
      'byRoot': serializer.toJson<String>(byRoot),
      'lamport': serializer.toJson<int>(lamport),
      'eventId': serializer.toJson<String>(eventId),
    };
  }

  TombstoneRow copyWith({
    String? target,
    String? byRoot,
    int? lamport,
    String? eventId,
  }) => TombstoneRow(
    target: target ?? this.target,
    byRoot: byRoot ?? this.byRoot,
    lamport: lamport ?? this.lamport,
    eventId: eventId ?? this.eventId,
  );
  TombstoneRow copyWithCompanion(TombstonesCompanion data) {
    return TombstoneRow(
      target: data.target.present ? data.target.value : this.target,
      byRoot: data.byRoot.present ? data.byRoot.value : this.byRoot,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TombstoneRow(')
          ..write('target: $target, ')
          ..write('byRoot: $byRoot, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(target, byRoot, lamport, eventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TombstoneRow &&
          other.target == this.target &&
          other.byRoot == this.byRoot &&
          other.lamport == this.lamport &&
          other.eventId == this.eventId);
}

class TombstonesCompanion extends UpdateCompanion<TombstoneRow> {
  final Value<String> target;
  final Value<String> byRoot;
  final Value<int> lamport;
  final Value<String> eventId;
  final Value<int> rowid;
  const TombstonesCompanion({
    this.target = const Value.absent(),
    this.byRoot = const Value.absent(),
    this.lamport = const Value.absent(),
    this.eventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TombstonesCompanion.insert({
    required String target,
    required String byRoot,
    required int lamport,
    required String eventId,
    this.rowid = const Value.absent(),
  }) : target = Value(target),
       byRoot = Value(byRoot),
       lamport = Value(lamport),
       eventId = Value(eventId);
  static Insertable<TombstoneRow> custom({
    Expression<String>? target,
    Expression<String>? byRoot,
    Expression<int>? lamport,
    Expression<String>? eventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (target != null) 'target': target,
      if (byRoot != null) 'by_root': byRoot,
      if (lamport != null) 'lamport': lamport,
      if (eventId != null) 'event_id': eventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TombstonesCompanion copyWith({
    Value<String>? target,
    Value<String>? byRoot,
    Value<int>? lamport,
    Value<String>? eventId,
    Value<int>? rowid,
  }) {
    return TombstonesCompanion(
      target: target ?? this.target,
      byRoot: byRoot ?? this.byRoot,
      lamport: lamport ?? this.lamport,
      eventId: eventId ?? this.eventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (byRoot.present) {
      map['by_root'] = Variable<String>(byRoot.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TombstonesCompanion(')
          ..write('target: $target, ')
          ..write('byRoot: $byRoot, ')
          ..write('lamport: $lamport, ')
          ..write('eventId: $eventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvelopesTable extends Envelopes
    with TableInfo<$EnvelopesTable, EnvelopeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvelopesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
    'hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ackHashMeta = const VerificationMeta(
    'ackHash',
  );
  @override
  late final GeneratedColumn<String> ackHash = GeneratedColumn<String>(
    'ack_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expMeta = const VerificationMeta('exp');
  @override
  late final GeneratedColumn<int> exp = GeneratedColumn<int>(
    'exp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hopsMeta = const VerificationMeta('hops');
  @override
  late final GeneratedColumn<int> hops = GeneratedColumn<int>(
    'hops',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<int> origin = GeneratedColumn<int>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ackedMeta = const VerificationMeta('acked');
  @override
  late final GeneratedColumn<bool> acked = GeneratedColumn<bool>(
    'acked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    raw,
    hint,
    ackHash,
    exp,
    size,
    receivedAt,
    hops,
    origin,
    acked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'envelopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvelopeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
        _hintMeta,
        hint.isAcceptableOrUnknown(data['hint']!, _hintMeta),
      );
    } else if (isInserting) {
      context.missing(_hintMeta);
    }
    if (data.containsKey('ack_hash')) {
      context.handle(
        _ackHashMeta,
        ackHash.isAcceptableOrUnknown(data['ack_hash']!, _ackHashMeta),
      );
    } else if (isInserting) {
      context.missing(_ackHashMeta);
    }
    if (data.containsKey('exp')) {
      context.handle(
        _expMeta,
        exp.isAcceptableOrUnknown(data['exp']!, _expMeta),
      );
    } else if (isInserting) {
      context.missing(_expMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('hops')) {
      context.handle(
        _hopsMeta,
        hops.isAcceptableOrUnknown(data['hops']!, _hopsMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('acked')) {
      context.handle(
        _ackedMeta,
        acked.isAcceptableOrUnknown(data['acked']!, _ackedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvelopeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvelopeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      hint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hint'],
      )!,
      ackHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_hash'],
      )!,
      exp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exp'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      hops: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hops'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin'],
      )!,
      acked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acked'],
      )!,
    );
  }

  @override
  $EnvelopesTable createAlias(String alias) {
    return $EnvelopesTable(attachedDatabase, alias);
  }
}

class EnvelopeRow extends DataClass implements Insertable<EnvelopeRow> {
  final String id;
  final String raw;
  final String hint;
  final String ackHash;
  final int exp;
  final int size;
  final int receivedAt;
  final int hops;
  final int origin;
  final bool acked;
  const EnvelopeRow({
    required this.id,
    required this.raw,
    required this.hint,
    required this.ackHash,
    required this.exp,
    required this.size,
    required this.receivedAt,
    required this.hops,
    required this.origin,
    required this.acked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['raw'] = Variable<String>(raw);
    map['hint'] = Variable<String>(hint);
    map['ack_hash'] = Variable<String>(ackHash);
    map['exp'] = Variable<int>(exp);
    map['size'] = Variable<int>(size);
    map['received_at'] = Variable<int>(receivedAt);
    map['hops'] = Variable<int>(hops);
    map['origin'] = Variable<int>(origin);
    map['acked'] = Variable<bool>(acked);
    return map;
  }

  EnvelopesCompanion toCompanion(bool nullToAbsent) {
    return EnvelopesCompanion(
      id: Value(id),
      raw: Value(raw),
      hint: Value(hint),
      ackHash: Value(ackHash),
      exp: Value(exp),
      size: Value(size),
      receivedAt: Value(receivedAt),
      hops: Value(hops),
      origin: Value(origin),
      acked: Value(acked),
    );
  }

  factory EnvelopeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvelopeRow(
      id: serializer.fromJson<String>(json['id']),
      raw: serializer.fromJson<String>(json['raw']),
      hint: serializer.fromJson<String>(json['hint']),
      ackHash: serializer.fromJson<String>(json['ackHash']),
      exp: serializer.fromJson<int>(json['exp']),
      size: serializer.fromJson<int>(json['size']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      hops: serializer.fromJson<int>(json['hops']),
      origin: serializer.fromJson<int>(json['origin']),
      acked: serializer.fromJson<bool>(json['acked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'raw': serializer.toJson<String>(raw),
      'hint': serializer.toJson<String>(hint),
      'ackHash': serializer.toJson<String>(ackHash),
      'exp': serializer.toJson<int>(exp),
      'size': serializer.toJson<int>(size),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'hops': serializer.toJson<int>(hops),
      'origin': serializer.toJson<int>(origin),
      'acked': serializer.toJson<bool>(acked),
    };
  }

  EnvelopeRow copyWith({
    String? id,
    String? raw,
    String? hint,
    String? ackHash,
    int? exp,
    int? size,
    int? receivedAt,
    int? hops,
    int? origin,
    bool? acked,
  }) => EnvelopeRow(
    id: id ?? this.id,
    raw: raw ?? this.raw,
    hint: hint ?? this.hint,
    ackHash: ackHash ?? this.ackHash,
    exp: exp ?? this.exp,
    size: size ?? this.size,
    receivedAt: receivedAt ?? this.receivedAt,
    hops: hops ?? this.hops,
    origin: origin ?? this.origin,
    acked: acked ?? this.acked,
  );
  EnvelopeRow copyWithCompanion(EnvelopesCompanion data) {
    return EnvelopeRow(
      id: data.id.present ? data.id.value : this.id,
      raw: data.raw.present ? data.raw.value : this.raw,
      hint: data.hint.present ? data.hint.value : this.hint,
      ackHash: data.ackHash.present ? data.ackHash.value : this.ackHash,
      exp: data.exp.present ? data.exp.value : this.exp,
      size: data.size.present ? data.size.value : this.size,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      hops: data.hops.present ? data.hops.value : this.hops,
      origin: data.origin.present ? data.origin.value : this.origin,
      acked: data.acked.present ? data.acked.value : this.acked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeRow(')
          ..write('id: $id, ')
          ..write('raw: $raw, ')
          ..write('hint: $hint, ')
          ..write('ackHash: $ackHash, ')
          ..write('exp: $exp, ')
          ..write('size: $size, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('hops: $hops, ')
          ..write('origin: $origin, ')
          ..write('acked: $acked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    raw,
    hint,
    ackHash,
    exp,
    size,
    receivedAt,
    hops,
    origin,
    acked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvelopeRow &&
          other.id == this.id &&
          other.raw == this.raw &&
          other.hint == this.hint &&
          other.ackHash == this.ackHash &&
          other.exp == this.exp &&
          other.size == this.size &&
          other.receivedAt == this.receivedAt &&
          other.hops == this.hops &&
          other.origin == this.origin &&
          other.acked == this.acked);
}

class EnvelopesCompanion extends UpdateCompanion<EnvelopeRow> {
  final Value<String> id;
  final Value<String> raw;
  final Value<String> hint;
  final Value<String> ackHash;
  final Value<int> exp;
  final Value<int> size;
  final Value<int> receivedAt;
  final Value<int> hops;
  final Value<int> origin;
  final Value<bool> acked;
  final Value<int> rowid;
  const EnvelopesCompanion({
    this.id = const Value.absent(),
    this.raw = const Value.absent(),
    this.hint = const Value.absent(),
    this.ackHash = const Value.absent(),
    this.exp = const Value.absent(),
    this.size = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.hops = const Value.absent(),
    this.origin = const Value.absent(),
    this.acked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvelopesCompanion.insert({
    required String id,
    required String raw,
    required String hint,
    required String ackHash,
    required int exp,
    required int size,
    required int receivedAt,
    this.hops = const Value.absent(),
    required int origin,
    this.acked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       raw = Value(raw),
       hint = Value(hint),
       ackHash = Value(ackHash),
       exp = Value(exp),
       size = Value(size),
       receivedAt = Value(receivedAt),
       origin = Value(origin);
  static Insertable<EnvelopeRow> custom({
    Expression<String>? id,
    Expression<String>? raw,
    Expression<String>? hint,
    Expression<String>? ackHash,
    Expression<int>? exp,
    Expression<int>? size,
    Expression<int>? receivedAt,
    Expression<int>? hops,
    Expression<int>? origin,
    Expression<bool>? acked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (raw != null) 'raw': raw,
      if (hint != null) 'hint': hint,
      if (ackHash != null) 'ack_hash': ackHash,
      if (exp != null) 'exp': exp,
      if (size != null) 'size': size,
      if (receivedAt != null) 'received_at': receivedAt,
      if (hops != null) 'hops': hops,
      if (origin != null) 'origin': origin,
      if (acked != null) 'acked': acked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvelopesCompanion copyWith({
    Value<String>? id,
    Value<String>? raw,
    Value<String>? hint,
    Value<String>? ackHash,
    Value<int>? exp,
    Value<int>? size,
    Value<int>? receivedAt,
    Value<int>? hops,
    Value<int>? origin,
    Value<bool>? acked,
    Value<int>? rowid,
  }) {
    return EnvelopesCompanion(
      id: id ?? this.id,
      raw: raw ?? this.raw,
      hint: hint ?? this.hint,
      ackHash: ackHash ?? this.ackHash,
      exp: exp ?? this.exp,
      size: size ?? this.size,
      receivedAt: receivedAt ?? this.receivedAt,
      hops: hops ?? this.hops,
      origin: origin ?? this.origin,
      acked: acked ?? this.acked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (ackHash.present) {
      map['ack_hash'] = Variable<String>(ackHash.value);
    }
    if (exp.present) {
      map['exp'] = Variable<int>(exp.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (hops.present) {
      map['hops'] = Variable<int>(hops.value);
    }
    if (origin.present) {
      map['origin'] = Variable<int>(origin.value);
    }
    if (acked.present) {
      map['acked'] = Variable<bool>(acked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopesCompanion(')
          ..write('id: $id, ')
          ..write('raw: $raw, ')
          ..write('hint: $hint, ')
          ..write('ackHash: $ackHash, ')
          ..write('exp: $exp, ')
          ..write('size: $size, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('hops: $hops, ')
          ..write('origin: $origin, ')
          ..write('acked: $acked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AcksTable extends Acks with TableInfo<$AcksTable, AckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ackHashMeta = const VerificationMeta(
    'ackHash',
  );
  @override
  late final GeneratedColumn<String> ackHash = GeneratedColumn<String>(
    'ack_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretMeta = const VerificationMeta('secret');
  @override
  late final GeneratedColumn<String> secret = GeneratedColumn<String>(
    'secret',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expMeta = const VerificationMeta('exp');
  @override
  late final GeneratedColumn<int> exp = GeneratedColumn<int>(
    'exp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ackHash, secret, exp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'acks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ack_hash')) {
      context.handle(
        _ackHashMeta,
        ackHash.isAcceptableOrUnknown(data['ack_hash']!, _ackHashMeta),
      );
    } else if (isInserting) {
      context.missing(_ackHashMeta);
    }
    if (data.containsKey('secret')) {
      context.handle(
        _secretMeta,
        secret.isAcceptableOrUnknown(data['secret']!, _secretMeta),
      );
    } else if (isInserting) {
      context.missing(_secretMeta);
    }
    if (data.containsKey('exp')) {
      context.handle(
        _expMeta,
        exp.isAcceptableOrUnknown(data['exp']!, _expMeta),
      );
    } else if (isInserting) {
      context.missing(_expMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ackHash};
  @override
  AckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AckRow(
      ackHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_hash'],
      )!,
      secret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret'],
      )!,
      exp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exp'],
      )!,
    );
  }

  @override
  $AcksTable createAlias(String alias) {
    return $AcksTable(attachedDatabase, alias);
  }
}

class AckRow extends DataClass implements Insertable<AckRow> {
  final String ackHash;
  final String secret;
  final int exp;
  const AckRow({
    required this.ackHash,
    required this.secret,
    required this.exp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ack_hash'] = Variable<String>(ackHash);
    map['secret'] = Variable<String>(secret);
    map['exp'] = Variable<int>(exp);
    return map;
  }

  AcksCompanion toCompanion(bool nullToAbsent) {
    return AcksCompanion(
      ackHash: Value(ackHash),
      secret: Value(secret),
      exp: Value(exp),
    );
  }

  factory AckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AckRow(
      ackHash: serializer.fromJson<String>(json['ackHash']),
      secret: serializer.fromJson<String>(json['secret']),
      exp: serializer.fromJson<int>(json['exp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ackHash': serializer.toJson<String>(ackHash),
      'secret': serializer.toJson<String>(secret),
      'exp': serializer.toJson<int>(exp),
    };
  }

  AckRow copyWith({String? ackHash, String? secret, int? exp}) => AckRow(
    ackHash: ackHash ?? this.ackHash,
    secret: secret ?? this.secret,
    exp: exp ?? this.exp,
  );
  AckRow copyWithCompanion(AcksCompanion data) {
    return AckRow(
      ackHash: data.ackHash.present ? data.ackHash.value : this.ackHash,
      secret: data.secret.present ? data.secret.value : this.secret,
      exp: data.exp.present ? data.exp.value : this.exp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AckRow(')
          ..write('ackHash: $ackHash, ')
          ..write('secret: $secret, ')
          ..write('exp: $exp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ackHash, secret, exp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AckRow &&
          other.ackHash == this.ackHash &&
          other.secret == this.secret &&
          other.exp == this.exp);
}

class AcksCompanion extends UpdateCompanion<AckRow> {
  final Value<String> ackHash;
  final Value<String> secret;
  final Value<int> exp;
  final Value<int> rowid;
  const AcksCompanion({
    this.ackHash = const Value.absent(),
    this.secret = const Value.absent(),
    this.exp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AcksCompanion.insert({
    required String ackHash,
    required String secret,
    required int exp,
    this.rowid = const Value.absent(),
  }) : ackHash = Value(ackHash),
       secret = Value(secret),
       exp = Value(exp);
  static Insertable<AckRow> custom({
    Expression<String>? ackHash,
    Expression<String>? secret,
    Expression<int>? exp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ackHash != null) 'ack_hash': ackHash,
      if (secret != null) 'secret': secret,
      if (exp != null) 'exp': exp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AcksCompanion copyWith({
    Value<String>? ackHash,
    Value<String>? secret,
    Value<int>? exp,
    Value<int>? rowid,
  }) {
    return AcksCompanion(
      ackHash: ackHash ?? this.ackHash,
      secret: secret ?? this.secret,
      exp: exp ?? this.exp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ackHash.present) {
      map['ack_hash'] = Variable<String>(ackHash.value);
    }
    if (secret.present) {
      map['secret'] = Variable<String>(secret.value);
    }
    if (exp.present) {
      map['exp'] = Variable<int>(exp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcksCompanion(')
          ..write('ackHash: $ackHash, ')
          ..write('secret: $secret, ')
          ..write('exp: $exp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerRootMeta = const VerificationMeta(
    'peerRoot',
  );
  @override
  late final GeneratedColumn<String> peerRoot = GeneratedColumn<String>(
    'peer_root',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outgoingMeta = const VerificationMeta(
    'outgoing',
  );
  @override
  late final GeneratedColumn<bool> outgoing = GeneratedColumn<bool>(
    'outgoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("outgoing" IN (0, 1))',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<int> sentAt = GeneratedColumn<int>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ackHashMeta = const VerificationMeta(
    'ackHash',
  );
  @override
  late final GeneratedColumn<String> ackHash = GeneratedColumn<String>(
    'ack_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveredMeta = const VerificationMeta(
    'delivered',
  );
  @override
  late final GeneratedColumn<bool> delivered = GeneratedColumn<bool>(
    'delivered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delivered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    peerRoot,
    outgoing,
    body,
    sentAt,
    receivedAt,
    ackHash,
    delivered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('peer_root')) {
      context.handle(
        _peerRootMeta,
        peerRoot.isAcceptableOrUnknown(data['peer_root']!, _peerRootMeta),
      );
    } else if (isInserting) {
      context.missing(_peerRootMeta);
    }
    if (data.containsKey('outgoing')) {
      context.handle(
        _outgoingMeta,
        outgoing.isAcceptableOrUnknown(data['outgoing']!, _outgoingMeta),
      );
    } else if (isInserting) {
      context.missing(_outgoingMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('ack_hash')) {
      context.handle(
        _ackHashMeta,
        ackHash.isAcceptableOrUnknown(data['ack_hash']!, _ackHashMeta),
      );
    } else if (isInserting) {
      context.missing(_ackHashMeta);
    }
    if (data.containsKey('delivered')) {
      context.handle(
        _deliveredMeta,
        delivered.isAcceptableOrUnknown(data['delivered']!, _deliveredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      peerRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_root'],
      )!,
      outgoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}outgoing'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      ),
      ackHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_hash'],
      )!,
      delivered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}delivered'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  /// Envelope id.
  final String id;
  final String peerRoot;
  final bool outgoing;
  final String body;
  final int sentAt;
  final int? receivedAt;
  final String ackHash;
  final bool delivered;
  const MessageRow({
    required this.id,
    required this.peerRoot,
    required this.outgoing,
    required this.body,
    required this.sentAt,
    this.receivedAt,
    required this.ackHash,
    required this.delivered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['peer_root'] = Variable<String>(peerRoot);
    map['outgoing'] = Variable<bool>(outgoing);
    map['body'] = Variable<String>(body);
    map['sent_at'] = Variable<int>(sentAt);
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<int>(receivedAt);
    }
    map['ack_hash'] = Variable<String>(ackHash);
    map['delivered'] = Variable<bool>(delivered);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      peerRoot: Value(peerRoot),
      outgoing: Value(outgoing),
      body: Value(body),
      sentAt: Value(sentAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      ackHash: Value(ackHash),
      delivered: Value(delivered),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      peerRoot: serializer.fromJson<String>(json['peerRoot']),
      outgoing: serializer.fromJson<bool>(json['outgoing']),
      body: serializer.fromJson<String>(json['body']),
      sentAt: serializer.fromJson<int>(json['sentAt']),
      receivedAt: serializer.fromJson<int?>(json['receivedAt']),
      ackHash: serializer.fromJson<String>(json['ackHash']),
      delivered: serializer.fromJson<bool>(json['delivered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'peerRoot': serializer.toJson<String>(peerRoot),
      'outgoing': serializer.toJson<bool>(outgoing),
      'body': serializer.toJson<String>(body),
      'sentAt': serializer.toJson<int>(sentAt),
      'receivedAt': serializer.toJson<int?>(receivedAt),
      'ackHash': serializer.toJson<String>(ackHash),
      'delivered': serializer.toJson<bool>(delivered),
    };
  }

  MessageRow copyWith({
    String? id,
    String? peerRoot,
    bool? outgoing,
    String? body,
    int? sentAt,
    Value<int?> receivedAt = const Value.absent(),
    String? ackHash,
    bool? delivered,
  }) => MessageRow(
    id: id ?? this.id,
    peerRoot: peerRoot ?? this.peerRoot,
    outgoing: outgoing ?? this.outgoing,
    body: body ?? this.body,
    sentAt: sentAt ?? this.sentAt,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    ackHash: ackHash ?? this.ackHash,
    delivered: delivered ?? this.delivered,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      peerRoot: data.peerRoot.present ? data.peerRoot.value : this.peerRoot,
      outgoing: data.outgoing.present ? data.outgoing.value : this.outgoing,
      body: data.body.present ? data.body.value : this.body,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      ackHash: data.ackHash.present ? data.ackHash.value : this.ackHash,
      delivered: data.delivered.present ? data.delivered.value : this.delivered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('peerRoot: $peerRoot, ')
          ..write('outgoing: $outgoing, ')
          ..write('body: $body, ')
          ..write('sentAt: $sentAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('ackHash: $ackHash, ')
          ..write('delivered: $delivered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    peerRoot,
    outgoing,
    body,
    sentAt,
    receivedAt,
    ackHash,
    delivered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.peerRoot == this.peerRoot &&
          other.outgoing == this.outgoing &&
          other.body == this.body &&
          other.sentAt == this.sentAt &&
          other.receivedAt == this.receivedAt &&
          other.ackHash == this.ackHash &&
          other.delivered == this.delivered);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> peerRoot;
  final Value<bool> outgoing;
  final Value<String> body;
  final Value<int> sentAt;
  final Value<int?> receivedAt;
  final Value<String> ackHash;
  final Value<bool> delivered;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.peerRoot = const Value.absent(),
    this.outgoing = const Value.absent(),
    this.body = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.ackHash = const Value.absent(),
    this.delivered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String peerRoot,
    required bool outgoing,
    required String body,
    required int sentAt,
    this.receivedAt = const Value.absent(),
    required String ackHash,
    this.delivered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       peerRoot = Value(peerRoot),
       outgoing = Value(outgoing),
       body = Value(body),
       sentAt = Value(sentAt),
       ackHash = Value(ackHash);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? peerRoot,
    Expression<bool>? outgoing,
    Expression<String>? body,
    Expression<int>? sentAt,
    Expression<int>? receivedAt,
    Expression<String>? ackHash,
    Expression<bool>? delivered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (peerRoot != null) 'peer_root': peerRoot,
      if (outgoing != null) 'outgoing': outgoing,
      if (body != null) 'body': body,
      if (sentAt != null) 'sent_at': sentAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (ackHash != null) 'ack_hash': ackHash,
      if (delivered != null) 'delivered': delivered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? peerRoot,
    Value<bool>? outgoing,
    Value<String>? body,
    Value<int>? sentAt,
    Value<int?>? receivedAt,
    Value<String>? ackHash,
    Value<bool>? delivered,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      peerRoot: peerRoot ?? this.peerRoot,
      outgoing: outgoing ?? this.outgoing,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      receivedAt: receivedAt ?? this.receivedAt,
      ackHash: ackHash ?? this.ackHash,
      delivered: delivered ?? this.delivered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (peerRoot.present) {
      map['peer_root'] = Variable<String>(peerRoot.value);
    }
    if (outgoing.present) {
      map['outgoing'] = Variable<bool>(outgoing.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<int>(sentAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (ackHash.present) {
      map['ack_hash'] = Variable<String>(ackHash.value);
    }
    if (delivered.present) {
      map['delivered'] = Variable<bool>(delivered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('peerRoot: $peerRoot, ')
          ..write('outgoing: $outgoing, ')
          ..write('body: $body, ')
          ..write('sentAt: $sentAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('ackHash: $ackHash, ')
          ..write('delivered: $delivered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlocksTable extends Blocks with TableInfo<$BlocksTable, BlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sinceMeta = const VerificationMeta('since');
  @override
  late final GeneratedColumn<int> since = GeneratedColumn<int>(
    'since',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, since];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('since')) {
      context.handle(
        _sinceMeta,
        since.isAcceptableOrUnknown(data['since']!, _sinceMeta),
      );
    } else if (isInserting) {
      context.missing(_sinceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  BlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      since: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}since'],
      )!,
    );
  }

  @override
  $BlocksTable createAlias(String alias) {
    return $BlocksTable(attachedDatabase, alias);
  }
}

class BlockRow extends DataClass implements Insertable<BlockRow> {
  final String rootId;
  final int since;
  const BlockRow({required this.rootId, required this.since});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['since'] = Variable<int>(since);
    return map;
  }

  BlocksCompanion toCompanion(bool nullToAbsent) {
    return BlocksCompanion(rootId: Value(rootId), since: Value(since));
  }

  factory BlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      since: serializer.fromJson<int>(json['since']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'since': serializer.toJson<int>(since),
    };
  }

  BlockRow copyWith({String? rootId, int? since}) =>
      BlockRow(rootId: rootId ?? this.rootId, since: since ?? this.since);
  BlockRow copyWithCompanion(BlocksCompanion data) {
    return BlockRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      since: data.since.present ? data.since.value : this.since,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockRow(')
          ..write('rootId: $rootId, ')
          ..write('since: $since')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, since);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockRow &&
          other.rootId == this.rootId &&
          other.since == this.since);
}

class BlocksCompanion extends UpdateCompanion<BlockRow> {
  final Value<String> rootId;
  final Value<int> since;
  final Value<int> rowid;
  const BlocksCompanion({
    this.rootId = const Value.absent(),
    this.since = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlocksCompanion.insert({
    required String rootId,
    required int since,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       since = Value(since);
  static Insertable<BlockRow> custom({
    Expression<String>? rootId,
    Expression<int>? since,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (since != null) 'since': since,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlocksCompanion copyWith({
    Value<String>? rootId,
    Value<int>? since,
    Value<int>? rowid,
  }) {
    return BlocksCompanion(
      rootId: rootId ?? this.rootId,
      since: since ?? this.since,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (since.present) {
      map['since'] = Variable<int>(since.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlocksCompanion(')
          ..write('rootId: $rootId, ')
          ..write('since: $since, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeersSeenTable extends PeersSeen
    with TableInfo<$PeersSeenTable, PeerSeenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeersSeenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encountersMeta = const VerificationMeta(
    'encounters',
  );
  @override
  late final GeneratedColumn<int> encounters = GeneratedColumn<int>(
    'encounters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [feedId, rootId, lastSeen, encounters];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peers_seen';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeerSeenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('encounters')) {
      context.handle(
        _encountersMeta,
        encounters.isAcceptableOrUnknown(data['encounters']!, _encountersMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedId};
  @override
  PeerSeenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeerSeenRow(
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
      encounters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}encounters'],
      )!,
    );
  }

  @override
  $PeersSeenTable createAlias(String alias) {
    return $PeersSeenTable(attachedDatabase, alias);
  }
}

class PeerSeenRow extends DataClass implements Insertable<PeerSeenRow> {
  final String feedId;
  final String rootId;
  final int lastSeen;
  final int encounters;
  const PeerSeenRow({
    required this.feedId,
    required this.rootId,
    required this.lastSeen,
    required this.encounters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_id'] = Variable<String>(feedId);
    map['root_id'] = Variable<String>(rootId);
    map['last_seen'] = Variable<int>(lastSeen);
    map['encounters'] = Variable<int>(encounters);
    return map;
  }

  PeersSeenCompanion toCompanion(bool nullToAbsent) {
    return PeersSeenCompanion(
      feedId: Value(feedId),
      rootId: Value(rootId),
      lastSeen: Value(lastSeen),
      encounters: Value(encounters),
    );
  }

  factory PeerSeenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeerSeenRow(
      feedId: serializer.fromJson<String>(json['feedId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      lastSeen: serializer.fromJson<int>(json['lastSeen']),
      encounters: serializer.fromJson<int>(json['encounters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedId': serializer.toJson<String>(feedId),
      'rootId': serializer.toJson<String>(rootId),
      'lastSeen': serializer.toJson<int>(lastSeen),
      'encounters': serializer.toJson<int>(encounters),
    };
  }

  PeerSeenRow copyWith({
    String? feedId,
    String? rootId,
    int? lastSeen,
    int? encounters,
  }) => PeerSeenRow(
    feedId: feedId ?? this.feedId,
    rootId: rootId ?? this.rootId,
    lastSeen: lastSeen ?? this.lastSeen,
    encounters: encounters ?? this.encounters,
  );
  PeerSeenRow copyWithCompanion(PeersSeenCompanion data) {
    return PeerSeenRow(
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      encounters: data.encounters.present
          ? data.encounters.value
          : this.encounters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeerSeenRow(')
          ..write('feedId: $feedId, ')
          ..write('rootId: $rootId, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('encounters: $encounters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedId, rootId, lastSeen, encounters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeerSeenRow &&
          other.feedId == this.feedId &&
          other.rootId == this.rootId &&
          other.lastSeen == this.lastSeen &&
          other.encounters == this.encounters);
}

class PeersSeenCompanion extends UpdateCompanion<PeerSeenRow> {
  final Value<String> feedId;
  final Value<String> rootId;
  final Value<int> lastSeen;
  final Value<int> encounters;
  final Value<int> rowid;
  const PeersSeenCompanion({
    this.feedId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.encounters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeersSeenCompanion.insert({
    required String feedId,
    required String rootId,
    required int lastSeen,
    this.encounters = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedId = Value(feedId),
       rootId = Value(rootId),
       lastSeen = Value(lastSeen);
  static Insertable<PeerSeenRow> custom({
    Expression<String>? feedId,
    Expression<String>? rootId,
    Expression<int>? lastSeen,
    Expression<int>? encounters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedId != null) 'feed_id': feedId,
      if (rootId != null) 'root_id': rootId,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (encounters != null) 'encounters': encounters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeersSeenCompanion copyWith({
    Value<String>? feedId,
    Value<String>? rootId,
    Value<int>? lastSeen,
    Value<int>? encounters,
    Value<int>? rowid,
  }) {
    return PeersSeenCompanion(
      feedId: feedId ?? this.feedId,
      rootId: rootId ?? this.rootId,
      lastSeen: lastSeen ?? this.lastSeen,
      encounters: encounters ?? this.encounters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (encounters.present) {
      map['encounters'] = Variable<int>(encounters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeersSeenCompanion(')
          ..write('feedId: $feedId, ')
          ..write('rootId: $rootId, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('encounters: $encounters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsTable extends Stats with TableInfo<$StatsTable, StatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  StatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $StatsTable createAlias(String alias) {
    return $StatsTable(attachedDatabase, alias);
  }
}

class StatRow extends DataClass implements Insertable<StatRow> {
  final String key;
  final int value;
  const StatRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  StatsCompanion toCompanion(bool nullToAbsent) {
    return StatsCompanion(key: Value(key), value: Value(value));
  }

  factory StatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  StatRow copyWith({String? key, int? value}) =>
      StatRow(key: key ?? this.key, value: value ?? this.value);
  StatRow copyWithCompanion(StatsCompanion data) {
    return StatRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatRow && other.key == this.key && other.value == this.value);
}

class StatsCompanion extends UpdateCompanion<StatRow> {
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const StatsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsCompanion.insert({
    required String key,
    required int value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<StatRow> custom({
    Expression<String>? key,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsCompanion copyWith({
    Value<String>? key,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return StatsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModActionsTable extends ModActions
    with TableInfo<$ModActionsTable, ModActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOnMeta = const VerificationMeta('isOn');
  @override
  late final GeneratedColumn<bool> isOn = GeneratedColumn<bool>(
    'is_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_on" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lamportMeta = const VerificationMeta(
    'lamport',
  );
  @override
  late final GeneratedColumn<int> lamport = GeneratedColumn<int>(
    'lamport',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validMeta = const VerificationMeta('valid');
  @override
  late final GeneratedColumn<bool> valid = GeneratedColumn<bool>(
    'valid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("valid" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    author,
    feedId,
    seq,
    type,
    target,
    isOn,
    lamport,
    ts,
    body,
    valid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mod_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('is_on')) {
      context.handle(
        _isOnMeta,
        isOn.isAcceptableOrUnknown(data['is_on']!, _isOnMeta),
      );
    }
    if (data.containsKey('lamport')) {
      context.handle(
        _lamportMeta,
        lamport.isAcceptableOrUnknown(data['lamport']!, _lamportMeta),
      );
    } else if (isInserting) {
      context.missing(_lamportMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('valid')) {
      context.handle(
        _validMeta,
        valid.isAcceptableOrUnknown(data['valid']!, _validMeta),
      );
    } else if (isInserting) {
      context.missing(_validMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ModActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModActionRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      isOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_on'],
      )!,
      lamport: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lamport'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      valid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}valid'],
      )!,
    );
  }

  @override
  $ModActionsTable createAlias(String alias) {
    return $ModActionsTable(attachedDatabase, alias);
  }
}

class ModActionRow extends DataClass implements Insertable<ModActionRow> {
  final String eventId;
  final String author;
  final String feedId;
  final int seq;
  final String type;
  final String target;

  /// For mod.ban: vote on (true) or retracted (false). Unused otherwise.
  final bool isOn;
  final int lamport;
  final int ts;

  /// Canonical JSON of the body (consent proof, revoke cutoffs, reason).
  final String body;

  /// Structural/cryptographic validity checked at ingest (e.g. consent sig).
  final bool valid;
  const ModActionRow({
    required this.eventId,
    required this.author,
    required this.feedId,
    required this.seq,
    required this.type,
    required this.target,
    required this.isOn,
    required this.lamport,
    required this.ts,
    required this.body,
    required this.valid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['author'] = Variable<String>(author);
    map['feed_id'] = Variable<String>(feedId);
    map['seq'] = Variable<int>(seq);
    map['type'] = Variable<String>(type);
    map['target'] = Variable<String>(target);
    map['is_on'] = Variable<bool>(isOn);
    map['lamport'] = Variable<int>(lamport);
    map['ts'] = Variable<int>(ts);
    map['body'] = Variable<String>(body);
    map['valid'] = Variable<bool>(valid);
    return map;
  }

  ModActionsCompanion toCompanion(bool nullToAbsent) {
    return ModActionsCompanion(
      eventId: Value(eventId),
      author: Value(author),
      feedId: Value(feedId),
      seq: Value(seq),
      type: Value(type),
      target: Value(target),
      isOn: Value(isOn),
      lamport: Value(lamport),
      ts: Value(ts),
      body: Value(body),
      valid: Value(valid),
    );
  }

  factory ModActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModActionRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      author: serializer.fromJson<String>(json['author']),
      feedId: serializer.fromJson<String>(json['feedId']),
      seq: serializer.fromJson<int>(json['seq']),
      type: serializer.fromJson<String>(json['type']),
      target: serializer.fromJson<String>(json['target']),
      isOn: serializer.fromJson<bool>(json['isOn']),
      lamport: serializer.fromJson<int>(json['lamport']),
      ts: serializer.fromJson<int>(json['ts']),
      body: serializer.fromJson<String>(json['body']),
      valid: serializer.fromJson<bool>(json['valid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'author': serializer.toJson<String>(author),
      'feedId': serializer.toJson<String>(feedId),
      'seq': serializer.toJson<int>(seq),
      'type': serializer.toJson<String>(type),
      'target': serializer.toJson<String>(target),
      'isOn': serializer.toJson<bool>(isOn),
      'lamport': serializer.toJson<int>(lamport),
      'ts': serializer.toJson<int>(ts),
      'body': serializer.toJson<String>(body),
      'valid': serializer.toJson<bool>(valid),
    };
  }

  ModActionRow copyWith({
    String? eventId,
    String? author,
    String? feedId,
    int? seq,
    String? type,
    String? target,
    bool? isOn,
    int? lamport,
    int? ts,
    String? body,
    bool? valid,
  }) => ModActionRow(
    eventId: eventId ?? this.eventId,
    author: author ?? this.author,
    feedId: feedId ?? this.feedId,
    seq: seq ?? this.seq,
    type: type ?? this.type,
    target: target ?? this.target,
    isOn: isOn ?? this.isOn,
    lamport: lamport ?? this.lamport,
    ts: ts ?? this.ts,
    body: body ?? this.body,
    valid: valid ?? this.valid,
  );
  ModActionRow copyWithCompanion(ModActionsCompanion data) {
    return ModActionRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      author: data.author.present ? data.author.value : this.author,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      seq: data.seq.present ? data.seq.value : this.seq,
      type: data.type.present ? data.type.value : this.type,
      target: data.target.present ? data.target.value : this.target,
      isOn: data.isOn.present ? data.isOn.value : this.isOn,
      lamport: data.lamport.present ? data.lamport.value : this.lamport,
      ts: data.ts.present ? data.ts.value : this.ts,
      body: data.body.present ? data.body.value : this.body,
      valid: data.valid.present ? data.valid.value : this.valid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModActionRow(')
          ..write('eventId: $eventId, ')
          ..write('author: $author, ')
          ..write('feedId: $feedId, ')
          ..write('seq: $seq, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('isOn: $isOn, ')
          ..write('lamport: $lamport, ')
          ..write('ts: $ts, ')
          ..write('body: $body, ')
          ..write('valid: $valid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    author,
    feedId,
    seq,
    type,
    target,
    isOn,
    lamport,
    ts,
    body,
    valid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModActionRow &&
          other.eventId == this.eventId &&
          other.author == this.author &&
          other.feedId == this.feedId &&
          other.seq == this.seq &&
          other.type == this.type &&
          other.target == this.target &&
          other.isOn == this.isOn &&
          other.lamport == this.lamport &&
          other.ts == this.ts &&
          other.body == this.body &&
          other.valid == this.valid);
}

class ModActionsCompanion extends UpdateCompanion<ModActionRow> {
  final Value<String> eventId;
  final Value<String> author;
  final Value<String> feedId;
  final Value<int> seq;
  final Value<String> type;
  final Value<String> target;
  final Value<bool> isOn;
  final Value<int> lamport;
  final Value<int> ts;
  final Value<String> body;
  final Value<bool> valid;
  final Value<int> rowid;
  const ModActionsCompanion({
    this.eventId = const Value.absent(),
    this.author = const Value.absent(),
    this.feedId = const Value.absent(),
    this.seq = const Value.absent(),
    this.type = const Value.absent(),
    this.target = const Value.absent(),
    this.isOn = const Value.absent(),
    this.lamport = const Value.absent(),
    this.ts = const Value.absent(),
    this.body = const Value.absent(),
    this.valid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModActionsCompanion.insert({
    required String eventId,
    required String author,
    required String feedId,
    required int seq,
    required String type,
    required String target,
    this.isOn = const Value.absent(),
    required int lamport,
    required int ts,
    required String body,
    required bool valid,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       author = Value(author),
       feedId = Value(feedId),
       seq = Value(seq),
       type = Value(type),
       target = Value(target),
       lamport = Value(lamport),
       ts = Value(ts),
       body = Value(body),
       valid = Value(valid);
  static Insertable<ModActionRow> custom({
    Expression<String>? eventId,
    Expression<String>? author,
    Expression<String>? feedId,
    Expression<int>? seq,
    Expression<String>? type,
    Expression<String>? target,
    Expression<bool>? isOn,
    Expression<int>? lamport,
    Expression<int>? ts,
    Expression<String>? body,
    Expression<bool>? valid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (author != null) 'author': author,
      if (feedId != null) 'feed_id': feedId,
      if (seq != null) 'seq': seq,
      if (type != null) 'type': type,
      if (target != null) 'target': target,
      if (isOn != null) 'is_on': isOn,
      if (lamport != null) 'lamport': lamport,
      if (ts != null) 'ts': ts,
      if (body != null) 'body': body,
      if (valid != null) 'valid': valid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModActionsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? author,
    Value<String>? feedId,
    Value<int>? seq,
    Value<String>? type,
    Value<String>? target,
    Value<bool>? isOn,
    Value<int>? lamport,
    Value<int>? ts,
    Value<String>? body,
    Value<bool>? valid,
    Value<int>? rowid,
  }) {
    return ModActionsCompanion(
      eventId: eventId ?? this.eventId,
      author: author ?? this.author,
      feedId: feedId ?? this.feedId,
      seq: seq ?? this.seq,
      type: type ?? this.type,
      target: target ?? this.target,
      isOn: isOn ?? this.isOn,
      lamport: lamport ?? this.lamport,
      ts: ts ?? this.ts,
      body: body ?? this.body,
      valid: valid ?? this.valid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (isOn.present) {
      map['is_on'] = Variable<bool>(isOn.value);
    }
    if (lamport.present) {
      map['lamport'] = Variable<int>(lamport.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (valid.present) {
      map['valid'] = Variable<bool>(valid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModActionsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('author: $author, ')
          ..write('feedId: $feedId, ')
          ..write('seq: $seq, ')
          ..write('type: $type, ')
          ..write('target: $target, ')
          ..write('isOn: $isOn, ')
          ..write('lamport: $lamport, ')
          ..write('ts: $ts, ')
          ..write('body: $body, ')
          ..write('valid: $valid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModeratorsTable extends Moderators
    with TableInfo<$ModeratorsTable, ModeratorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModeratorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vouchedByMeta = const VerificationMeta(
    'vouchedBy',
  );
  @override
  late final GeneratedColumn<String> vouchedBy = GeneratedColumn<String>(
    'vouched_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, role, vouchedBy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moderators';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModeratorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('vouched_by')) {
      context.handle(
        _vouchedByMeta,
        vouchedBy.isAcceptableOrUnknown(data['vouched_by']!, _vouchedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  ModeratorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModeratorRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      vouchedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vouched_by'],
      )!,
    );
  }

  @override
  $ModeratorsTable createAlias(String alias) {
    return $ModeratorsTable(attachedDatabase, alias);
  }
}

class ModeratorRow extends DataClass implements Insertable<ModeratorRow> {
  final String rootId;
  final int role;

  /// Roots whose vouches made this moderator (comma-separated, display only).
  final String vouchedBy;
  const ModeratorRow({
    required this.rootId,
    required this.role,
    required this.vouchedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['role'] = Variable<int>(role);
    map['vouched_by'] = Variable<String>(vouchedBy);
    return map;
  }

  ModeratorsCompanion toCompanion(bool nullToAbsent) {
    return ModeratorsCompanion(
      rootId: Value(rootId),
      role: Value(role),
      vouchedBy: Value(vouchedBy),
    );
  }

  factory ModeratorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModeratorRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      role: serializer.fromJson<int>(json['role']),
      vouchedBy: serializer.fromJson<String>(json['vouchedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'role': serializer.toJson<int>(role),
      'vouchedBy': serializer.toJson<String>(vouchedBy),
    };
  }

  ModeratorRow copyWith({String? rootId, int? role, String? vouchedBy}) =>
      ModeratorRow(
        rootId: rootId ?? this.rootId,
        role: role ?? this.role,
        vouchedBy: vouchedBy ?? this.vouchedBy,
      );
  ModeratorRow copyWithCompanion(ModeratorsCompanion data) {
    return ModeratorRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      role: data.role.present ? data.role.value : this.role,
      vouchedBy: data.vouchedBy.present ? data.vouchedBy.value : this.vouchedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModeratorRow(')
          ..write('rootId: $rootId, ')
          ..write('role: $role, ')
          ..write('vouchedBy: $vouchedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, role, vouchedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModeratorRow &&
          other.rootId == this.rootId &&
          other.role == this.role &&
          other.vouchedBy == this.vouchedBy);
}

class ModeratorsCompanion extends UpdateCompanion<ModeratorRow> {
  final Value<String> rootId;
  final Value<int> role;
  final Value<String> vouchedBy;
  final Value<int> rowid;
  const ModeratorsCompanion({
    this.rootId = const Value.absent(),
    this.role = const Value.absent(),
    this.vouchedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModeratorsCompanion.insert({
    required String rootId,
    required int role,
    this.vouchedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       role = Value(role);
  static Insertable<ModeratorRow> custom({
    Expression<String>? rootId,
    Expression<int>? role,
    Expression<String>? vouchedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (role != null) 'role': role,
      if (vouchedBy != null) 'vouched_by': vouchedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModeratorsCompanion copyWith({
    Value<String>? rootId,
    Value<int>? role,
    Value<String>? vouchedBy,
    Value<int>? rowid,
  }) {
    return ModeratorsCompanion(
      rootId: rootId ?? this.rootId,
      role: role ?? this.role,
      vouchedBy: vouchedBy ?? this.vouchedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (vouchedBy.present) {
      map['vouched_by'] = Variable<String>(vouchedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModeratorsCompanion(')
          ..write('rootId: $rootId, ')
          ..write('role: $role, ')
          ..write('vouchedBy: $vouchedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModStatusTable extends ModStatus
    with TableInfo<$ModStatusTable, ModStatusRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _votesMeta = const VerificationMeta('votes');
  @override
  late final GeneratedColumn<int> votes = GeneratedColumn<int>(
    'votes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, state, votes, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mod_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModStatusRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('votes')) {
      context.handle(
        _votesMeta,
        votes.isAcceptableOrUnknown(data['votes']!, _votesMeta),
      );
    } else if (isInserting) {
      context.missing(_votesMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  ModStatusRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModStatusRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      votes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}votes'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $ModStatusTable createAlias(String alias) {
    return $ModStatusTable(attachedDatabase, alias);
  }
}

class ModStatusRow extends DataClass implements Insertable<ModStatusRow> {
  final String rootId;
  final int state;
  final int votes;
  final String reason;
  const ModStatusRow({
    required this.rootId,
    required this.state,
    required this.votes,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['state'] = Variable<int>(state);
    map['votes'] = Variable<int>(votes);
    map['reason'] = Variable<String>(reason);
    return map;
  }

  ModStatusCompanion toCompanion(bool nullToAbsent) {
    return ModStatusCompanion(
      rootId: Value(rootId),
      state: Value(state),
      votes: Value(votes),
      reason: Value(reason),
    );
  }

  factory ModStatusRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModStatusRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      state: serializer.fromJson<int>(json['state']),
      votes: serializer.fromJson<int>(json['votes']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'state': serializer.toJson<int>(state),
      'votes': serializer.toJson<int>(votes),
      'reason': serializer.toJson<String>(reason),
    };
  }

  ModStatusRow copyWith({
    String? rootId,
    int? state,
    int? votes,
    String? reason,
  }) => ModStatusRow(
    rootId: rootId ?? this.rootId,
    state: state ?? this.state,
    votes: votes ?? this.votes,
    reason: reason ?? this.reason,
  );
  ModStatusRow copyWithCompanion(ModStatusCompanion data) {
    return ModStatusRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      state: data.state.present ? data.state.value : this.state,
      votes: data.votes.present ? data.votes.value : this.votes,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModStatusRow(')
          ..write('rootId: $rootId, ')
          ..write('state: $state, ')
          ..write('votes: $votes, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, state, votes, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModStatusRow &&
          other.rootId == this.rootId &&
          other.state == this.state &&
          other.votes == this.votes &&
          other.reason == this.reason);
}

class ModStatusCompanion extends UpdateCompanion<ModStatusRow> {
  final Value<String> rootId;
  final Value<int> state;
  final Value<int> votes;
  final Value<String> reason;
  final Value<int> rowid;
  const ModStatusCompanion({
    this.rootId = const Value.absent(),
    this.state = const Value.absent(),
    this.votes = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModStatusCompanion.insert({
    required String rootId,
    required int state,
    required int votes,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       state = Value(state),
       votes = Value(votes);
  static Insertable<ModStatusRow> custom({
    Expression<String>? rootId,
    Expression<int>? state,
    Expression<int>? votes,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (state != null) 'state': state,
      if (votes != null) 'votes': votes,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModStatusCompanion copyWith({
    Value<String>? rootId,
    Value<int>? state,
    Value<int>? votes,
    Value<String>? reason,
    Value<int>? rowid,
  }) {
    return ModStatusCompanion(
      rootId: rootId ?? this.rootId,
      state: state ?? this.state,
      votes: votes ?? this.votes,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (votes.present) {
      map['votes'] = Variable<int>(votes.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModStatusCompanion(')
          ..write('rootId: $rootId, ')
          ..write('state: $state, ')
          ..write('votes: $votes, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModRevocationsTable extends ModRevocations
    with TableInfo<$ModRevocationsTable, ModRevocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModRevocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cutoffMeta = const VerificationMeta('cutoff');
  @override
  late final GeneratedColumn<String> cutoff = GeneratedColumn<String>(
    'cutoff',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, cutoff];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mod_revocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModRevocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('cutoff')) {
      context.handle(
        _cutoffMeta,
        cutoff.isAcceptableOrUnknown(data['cutoff']!, _cutoffMeta),
      );
    } else if (isInserting) {
      context.missing(_cutoffMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  ModRevocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModRevocationRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      cutoff: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cutoff'],
      )!,
    );
  }

  @override
  $ModRevocationsTable createAlias(String alias) {
    return $ModRevocationsTable(attachedDatabase, alias);
  }
}

class ModRevocationRow extends DataClass
    implements Insertable<ModRevocationRow> {
  final String rootId;

  /// Canonical JSON map {feedId: lastValidSeq}.
  final String cutoff;
  const ModRevocationRow({required this.rootId, required this.cutoff});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['cutoff'] = Variable<String>(cutoff);
    return map;
  }

  ModRevocationsCompanion toCompanion(bool nullToAbsent) {
    return ModRevocationsCompanion(
      rootId: Value(rootId),
      cutoff: Value(cutoff),
    );
  }

  factory ModRevocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModRevocationRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      cutoff: serializer.fromJson<String>(json['cutoff']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'cutoff': serializer.toJson<String>(cutoff),
    };
  }

  ModRevocationRow copyWith({String? rootId, String? cutoff}) =>
      ModRevocationRow(
        rootId: rootId ?? this.rootId,
        cutoff: cutoff ?? this.cutoff,
      );
  ModRevocationRow copyWithCompanion(ModRevocationsCompanion data) {
    return ModRevocationRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      cutoff: data.cutoff.present ? data.cutoff.value : this.cutoff,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModRevocationRow(')
          ..write('rootId: $rootId, ')
          ..write('cutoff: $cutoff')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, cutoff);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModRevocationRow &&
          other.rootId == this.rootId &&
          other.cutoff == this.cutoff);
}

class ModRevocationsCompanion extends UpdateCompanion<ModRevocationRow> {
  final Value<String> rootId;
  final Value<String> cutoff;
  final Value<int> rowid;
  const ModRevocationsCompanion({
    this.rootId = const Value.absent(),
    this.cutoff = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModRevocationsCompanion.insert({
    required String rootId,
    required String cutoff,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       cutoff = Value(cutoff);
  static Insertable<ModRevocationRow> custom({
    Expression<String>? rootId,
    Expression<String>? cutoff,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (cutoff != null) 'cutoff': cutoff,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModRevocationsCompanion copyWith({
    Value<String>? rootId,
    Value<String>? cutoff,
    Value<int>? rowid,
  }) {
    return ModRevocationsCompanion(
      rootId: rootId ?? this.rootId,
      cutoff: cutoff ?? this.cutoff,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (cutoff.present) {
      map['cutoff'] = Variable<String>(cutoff.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModRevocationsCompanion(')
          ..write('rootId: $rootId, ')
          ..write('cutoff: $cutoff, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerifiedTable extends Verified
    with TableInfo<$VerifiedTable, VerifiedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerifiedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verified';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerifiedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  VerifiedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerifiedRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $VerifiedTable createAlias(String alias) {
    return $VerifiedTable(attachedDatabase, alias);
  }
}

class VerifiedRow extends DataClass implements Insertable<VerifiedRow> {
  final String rootId;
  final int at;
  const VerifiedRow({required this.rootId, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['at'] = Variable<int>(at);
    return map;
  }

  VerifiedCompanion toCompanion(bool nullToAbsent) {
    return VerifiedCompanion(rootId: Value(rootId), at: Value(at));
  }

  factory VerifiedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerifiedRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'at': serializer.toJson<int>(at),
    };
  }

  VerifiedRow copyWith({String? rootId, int? at}) =>
      VerifiedRow(rootId: rootId ?? this.rootId, at: at ?? this.at);
  VerifiedRow copyWithCompanion(VerifiedCompanion data) {
    return VerifiedRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerifiedRow(')
          ..write('rootId: $rootId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerifiedRow &&
          other.rootId == this.rootId &&
          other.at == this.at);
}

class VerifiedCompanion extends UpdateCompanion<VerifiedRow> {
  final Value<String> rootId;
  final Value<int> at;
  final Value<int> rowid;
  const VerifiedCompanion({
    this.rootId = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerifiedCompanion.insert({
    required String rootId,
    required int at,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       at = Value(at);
  static Insertable<VerifiedRow> custom({
    Expression<String>? rootId,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerifiedCompanion copyWith({
    Value<String>? rootId,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return VerifiedCompanion(
      rootId: rootId ?? this.rootId,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerifiedCompanion(')
          ..write('rootId: $rootId, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PetnamesTable extends Petnames
    with TableInfo<$PetnamesTable, PetnameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetnamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rootId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'petnames';
  @override
  VerificationContext validateIntegrity(
    Insertable<PetnameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootId};
  @override
  PetnameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PetnameRow(
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PetnamesTable createAlias(String alias) {
    return $PetnamesTable(attachedDatabase, alias);
  }
}

class PetnameRow extends DataClass implements Insertable<PetnameRow> {
  final String rootId;
  final String name;
  const PetnameRow({required this.rootId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_id'] = Variable<String>(rootId);
    map['name'] = Variable<String>(name);
    return map;
  }

  PetnamesCompanion toCompanion(bool nullToAbsent) {
    return PetnamesCompanion(rootId: Value(rootId), name: Value(name));
  }

  factory PetnameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PetnameRow(
      rootId: serializer.fromJson<String>(json['rootId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootId': serializer.toJson<String>(rootId),
      'name': serializer.toJson<String>(name),
    };
  }

  PetnameRow copyWith({String? rootId, String? name}) =>
      PetnameRow(rootId: rootId ?? this.rootId, name: name ?? this.name);
  PetnameRow copyWithCompanion(PetnamesCompanion data) {
    return PetnameRow(
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PetnameRow(')
          ..write('rootId: $rootId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rootId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PetnameRow &&
          other.rootId == this.rootId &&
          other.name == this.name);
}

class PetnamesCompanion extends UpdateCompanion<PetnameRow> {
  final Value<String> rootId;
  final Value<String> name;
  final Value<int> rowid;
  const PetnamesCompanion({
    this.rootId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PetnamesCompanion.insert({
    required String rootId,
    required String name,
    this.rowid = const Value.absent(),
  }) : rootId = Value(rootId),
       name = Value(name);
  static Insertable<PetnameRow> custom({
    Expression<String>? rootId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootId != null) 'root_id': rootId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PetnamesCompanion copyWith({
    Value<String>? rootId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return PetnamesCompanion(
      rootId: rootId ?? this.rootId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetnamesCompanion(')
          ..write('rootId: $rootId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaBlobsTable extends MediaBlobs
    with TableInfo<$MediaBlobsTable, MediaBlobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestMeta = const VerificationMeta(
    'manifest',
  );
  @override
  late final GeneratedColumn<String> manifest = GeneratedColumn<String>(
    'manifest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkCountMeta = const VerificationMeta(
    'chunkCount',
  );
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
    'chunk_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunksHeldMeta = const VerificationMeta(
    'chunksHeld',
  );
  @override
  late final GeneratedColumn<int> chunksHeld = GeneratedColumn<int>(
    'chunks_held',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completeMeta = const VerificationMeta(
    'complete',
  );
  @override
  late final GeneratedColumn<bool> complete = GeneratedColumn<bool>(
    'complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hash,
    manifest,
    mime,
    size,
    chunkCount,
    chunksHeld,
    complete,
    rootId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaBlobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('manifest')) {
      context.handle(
        _manifestMeta,
        manifest.isAcceptableOrUnknown(data['manifest']!, _manifestMeta),
      );
    } else if (isInserting) {
      context.missing(_manifestMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
        _chunkCountMeta,
        chunkCount.isAcceptableOrUnknown(data['chunk_count']!, _chunkCountMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkCountMeta);
    }
    if (data.containsKey('chunks_held')) {
      context.handle(
        _chunksHeldMeta,
        chunksHeld.isAcceptableOrUnknown(data['chunks_held']!, _chunksHeldMeta),
      );
    }
    if (data.containsKey('complete')) {
      context.handle(
        _completeMeta,
        complete.isAcceptableOrUnknown(data['complete']!, _completeMeta),
      );
    }
    if (data.containsKey('root_id')) {
      context.handle(
        _rootIdMeta,
        rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rootIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {hash};
  @override
  MediaBlobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaBlobRow(
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      manifest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      chunkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_count'],
      )!,
      chunksHeld: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunks_held'],
      )!,
      complete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}complete'],
      )!,
      rootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaBlobsTable createAlias(String alias) {
    return $MediaBlobsTable(attachedDatabase, alias);
  }
}

class MediaBlobRow extends DataClass implements Insertable<MediaBlobRow> {
  /// base64url SHA-256 of the whole file.
  final String hash;

  /// Canonical JSON of the MediaManifest.
  final String manifest;
  final String mime;
  final int size;
  final int chunkCount;
  final int chunksHeld;
  final bool complete;

  /// Author of the first post/profile that referenced it (for purges).
  final String rootId;
  final int createdAt;
  const MediaBlobRow({
    required this.hash,
    required this.manifest,
    required this.mime,
    required this.size,
    required this.chunkCount,
    required this.chunksHeld,
    required this.complete,
    required this.rootId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hash'] = Variable<String>(hash);
    map['manifest'] = Variable<String>(manifest);
    map['mime'] = Variable<String>(mime);
    map['size'] = Variable<int>(size);
    map['chunk_count'] = Variable<int>(chunkCount);
    map['chunks_held'] = Variable<int>(chunksHeld);
    map['complete'] = Variable<bool>(complete);
    map['root_id'] = Variable<String>(rootId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MediaBlobsCompanion toCompanion(bool nullToAbsent) {
    return MediaBlobsCompanion(
      hash: Value(hash),
      manifest: Value(manifest),
      mime: Value(mime),
      size: Value(size),
      chunkCount: Value(chunkCount),
      chunksHeld: Value(chunksHeld),
      complete: Value(complete),
      rootId: Value(rootId),
      createdAt: Value(createdAt),
    );
  }

  factory MediaBlobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaBlobRow(
      hash: serializer.fromJson<String>(json['hash']),
      manifest: serializer.fromJson<String>(json['manifest']),
      mime: serializer.fromJson<String>(json['mime']),
      size: serializer.fromJson<int>(json['size']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      chunksHeld: serializer.fromJson<int>(json['chunksHeld']),
      complete: serializer.fromJson<bool>(json['complete']),
      rootId: serializer.fromJson<String>(json['rootId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hash': serializer.toJson<String>(hash),
      'manifest': serializer.toJson<String>(manifest),
      'mime': serializer.toJson<String>(mime),
      'size': serializer.toJson<int>(size),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'chunksHeld': serializer.toJson<int>(chunksHeld),
      'complete': serializer.toJson<bool>(complete),
      'rootId': serializer.toJson<String>(rootId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MediaBlobRow copyWith({
    String? hash,
    String? manifest,
    String? mime,
    int? size,
    int? chunkCount,
    int? chunksHeld,
    bool? complete,
    String? rootId,
    int? createdAt,
  }) => MediaBlobRow(
    hash: hash ?? this.hash,
    manifest: manifest ?? this.manifest,
    mime: mime ?? this.mime,
    size: size ?? this.size,
    chunkCount: chunkCount ?? this.chunkCount,
    chunksHeld: chunksHeld ?? this.chunksHeld,
    complete: complete ?? this.complete,
    rootId: rootId ?? this.rootId,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaBlobRow copyWithCompanion(MediaBlobsCompanion data) {
    return MediaBlobRow(
      hash: data.hash.present ? data.hash.value : this.hash,
      manifest: data.manifest.present ? data.manifest.value : this.manifest,
      mime: data.mime.present ? data.mime.value : this.mime,
      size: data.size.present ? data.size.value : this.size,
      chunkCount: data.chunkCount.present
          ? data.chunkCount.value
          : this.chunkCount,
      chunksHeld: data.chunksHeld.present
          ? data.chunksHeld.value
          : this.chunksHeld,
      complete: data.complete.present ? data.complete.value : this.complete,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaBlobRow(')
          ..write('hash: $hash, ')
          ..write('manifest: $manifest, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('chunksHeld: $chunksHeld, ')
          ..write('complete: $complete, ')
          ..write('rootId: $rootId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hash,
    manifest,
    mime,
    size,
    chunkCount,
    chunksHeld,
    complete,
    rootId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaBlobRow &&
          other.hash == this.hash &&
          other.manifest == this.manifest &&
          other.mime == this.mime &&
          other.size == this.size &&
          other.chunkCount == this.chunkCount &&
          other.chunksHeld == this.chunksHeld &&
          other.complete == this.complete &&
          other.rootId == this.rootId &&
          other.createdAt == this.createdAt);
}

class MediaBlobsCompanion extends UpdateCompanion<MediaBlobRow> {
  final Value<String> hash;
  final Value<String> manifest;
  final Value<String> mime;
  final Value<int> size;
  final Value<int> chunkCount;
  final Value<int> chunksHeld;
  final Value<bool> complete;
  final Value<String> rootId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MediaBlobsCompanion({
    this.hash = const Value.absent(),
    this.manifest = const Value.absent(),
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.chunksHeld = const Value.absent(),
    this.complete = const Value.absent(),
    this.rootId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaBlobsCompanion.insert({
    required String hash,
    required String manifest,
    required String mime,
    required int size,
    required int chunkCount,
    this.chunksHeld = const Value.absent(),
    this.complete = const Value.absent(),
    required String rootId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : hash = Value(hash),
       manifest = Value(manifest),
       mime = Value(mime),
       size = Value(size),
       chunkCount = Value(chunkCount),
       rootId = Value(rootId),
       createdAt = Value(createdAt);
  static Insertable<MediaBlobRow> custom({
    Expression<String>? hash,
    Expression<String>? manifest,
    Expression<String>? mime,
    Expression<int>? size,
    Expression<int>? chunkCount,
    Expression<int>? chunksHeld,
    Expression<bool>? complete,
    Expression<String>? rootId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hash != null) 'hash': hash,
      if (manifest != null) 'manifest': manifest,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (chunksHeld != null) 'chunks_held': chunksHeld,
      if (complete != null) 'complete': complete,
      if (rootId != null) 'root_id': rootId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaBlobsCompanion copyWith({
    Value<String>? hash,
    Value<String>? manifest,
    Value<String>? mime,
    Value<int>? size,
    Value<int>? chunkCount,
    Value<int>? chunksHeld,
    Value<bool>? complete,
    Value<String>? rootId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaBlobsCompanion(
      hash: hash ?? this.hash,
      manifest: manifest ?? this.manifest,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      chunkCount: chunkCount ?? this.chunkCount,
      chunksHeld: chunksHeld ?? this.chunksHeld,
      complete: complete ?? this.complete,
      rootId: rootId ?? this.rootId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (manifest.present) {
      map['manifest'] = Variable<String>(manifest.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (chunksHeld.present) {
      map['chunks_held'] = Variable<int>(chunksHeld.value);
    }
    if (complete.present) {
      map['complete'] = Variable<bool>(complete.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaBlobsCompanion(')
          ..write('hash: $hash, ')
          ..write('manifest: $manifest, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('chunksHeld: $chunksHeld, ')
          ..write('complete: $complete, ')
          ..write('rootId: $rootId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaChunksTable extends MediaChunks
    with TableInfo<$MediaChunksTable, MediaChunkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hash, idx, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaChunkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hash, idx};
  @override
  MediaChunkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaChunkRow(
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $MediaChunksTable createAlias(String alias) {
    return $MediaChunksTable(attachedDatabase, alias);
  }
}

class MediaChunkRow extends DataClass implements Insertable<MediaChunkRow> {
  final String hash;
  final int idx;
  final Uint8List data;
  const MediaChunkRow({
    required this.hash,
    required this.idx,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hash'] = Variable<String>(hash);
    map['idx'] = Variable<int>(idx);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  MediaChunksCompanion toCompanion(bool nullToAbsent) {
    return MediaChunksCompanion(
      hash: Value(hash),
      idx: Value(idx),
      data: Value(data),
    );
  }

  factory MediaChunkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaChunkRow(
      hash: serializer.fromJson<String>(json['hash']),
      idx: serializer.fromJson<int>(json['idx']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hash': serializer.toJson<String>(hash),
      'idx': serializer.toJson<int>(idx),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  MediaChunkRow copyWith({String? hash, int? idx, Uint8List? data}) =>
      MediaChunkRow(
        hash: hash ?? this.hash,
        idx: idx ?? this.idx,
        data: data ?? this.data,
      );
  MediaChunkRow copyWithCompanion(MediaChunksCompanion data) {
    return MediaChunkRow(
      hash: data.hash.present ? data.hash.value : this.hash,
      idx: data.idx.present ? data.idx.value : this.idx,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaChunkRow(')
          ..write('hash: $hash, ')
          ..write('idx: $idx, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hash, idx, $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaChunkRow &&
          other.hash == this.hash &&
          other.idx == this.idx &&
          $driftBlobEquality.equals(other.data, this.data));
}

class MediaChunksCompanion extends UpdateCompanion<MediaChunkRow> {
  final Value<String> hash;
  final Value<int> idx;
  final Value<Uint8List> data;
  final Value<int> rowid;
  const MediaChunksCompanion({
    this.hash = const Value.absent(),
    this.idx = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaChunksCompanion.insert({
    required String hash,
    required int idx,
    required Uint8List data,
    this.rowid = const Value.absent(),
  }) : hash = Value(hash),
       idx = Value(idx),
       data = Value(data);
  static Insertable<MediaChunkRow> custom({
    Expression<String>? hash,
    Expression<int>? idx,
    Expression<Uint8List>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hash != null) 'hash': hash,
      if (idx != null) 'idx': idx,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaChunksCompanion copyWith({
    Value<String>? hash,
    Value<int>? idx,
    Value<Uint8List>? data,
    Value<int>? rowid,
  }) {
    return MediaChunksCompanion(
      hash: hash ?? this.hash,
      idx: idx ?? this.idx,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaChunksCompanion(')
          ..write('hash: $hash, ')
          ..write('idx: $idx, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$JaalDatabase extends GeneratedDatabase {
  _$JaalDatabase(QueryExecutor e) : super(e);
  $JaalDatabaseManager get managers => $JaalDatabaseManager(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $ReactionsTable reactions = $ReactionsTable(this);
  late final $CommentsTable comments = $CommentsTable(this);
  late final $FollowsTable follows = $FollowsTable(this);
  late final $TombstonesTable tombstones = $TombstonesTable(this);
  late final $EnvelopesTable envelopes = $EnvelopesTable(this);
  late final $AcksTable acks = $AcksTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $BlocksTable blocks = $BlocksTable(this);
  late final $PeersSeenTable peersSeen = $PeersSeenTable(this);
  late final $StatsTable stats = $StatsTable(this);
  late final $ModActionsTable modActions = $ModActionsTable(this);
  late final $ModeratorsTable moderators = $ModeratorsTable(this);
  late final $ModStatusTable modStatus = $ModStatusTable(this);
  late final $ModRevocationsTable modRevocations = $ModRevocationsTable(this);
  late final $VerifiedTable verified = $VerifiedTable(this);
  late final $PetnamesTable petnames = $PetnamesTable(this);
  late final $MediaBlobsTable mediaBlobs = $MediaBlobsTable(this);
  late final $MediaChunksTable mediaChunks = $MediaChunksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    feeds,
    events,
    profiles,
    posts,
    reactions,
    comments,
    follows,
    tombstones,
    envelopes,
    acks,
    messages,
    blocks,
    peersSeen,
    stats,
    modActions,
    moderators,
    modStatus,
    modRevocations,
    verified,
    petnames,
    mediaBlobs,
    mediaChunks,
  ];
}

typedef $$FeedsTableCreateCompanionBuilder = FeedsCompanion Function({
  required String feedId,
  required String rootId,
  Value<int> latestSeq,
  Value<String?> latestId,
  Value<int> latestLamport,
  Value<int?> revokedAfterSeq,
  Value<int> purpose,
  Value<int> rowid,
});
typedef $$FeedsTableUpdateCompanionBuilder = FeedsCompanion Function({
  Value<String> feedId,
  Value<String> rootId,
  Value<int> latestSeq,
  Value<String?> latestId,
  Value<int> latestLamport,
  Value<int?> revokedAfterSeq,
  Value<int> purpose,
  Value<int> rowid,
});

class $$FeedsTableFilterComposer extends Composer<_$JaalDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latestSeq => $composableBuilder(
    column: $table.latestSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestId => $composableBuilder(
    column: $table.latestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latestLamport => $composableBuilder(
    column: $table.latestLamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revokedAfterSeq => $composableBuilder(
    column: $table.revokedAfterSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedsTableOrderingComposer
    extends Composer<_$JaalDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latestSeq => $composableBuilder(
    column: $table.latestSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestId => $composableBuilder(
    column: $table.latestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latestLamport => $composableBuilder(
    column: $table.latestLamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revokedAfterSeq => $composableBuilder(
    column: $table.revokedAfterSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get latestSeq =>
      $composableBuilder(column: $table.latestSeq, builder: (column) => column);

  GeneratedColumn<String> get latestId =>
      $composableBuilder(column: $table.latestId, builder: (column) => column);

  GeneratedColumn<int> get latestLamport => $composableBuilder(
    column: $table.latestLamport,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revokedAfterSeq => $composableBuilder(
    column: $table.revokedAfterSeq,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);
}

class $$FeedsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $FeedsTable,
          FeedRow,
          $$FeedsTableFilterComposer,
          $$FeedsTableOrderingComposer,
          $$FeedsTableAnnotationComposer,
          $$FeedsTableCreateCompanionBuilder,
          $$FeedsTableUpdateCompanionBuilder,
          (FeedRow, BaseReferences<_$JaalDatabase, $FeedsTable, FeedRow>),
          FeedRow,
          PrefetchHooks Function()
        > {
  $$FeedsTableTableManager(_$JaalDatabase db, $FeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> latestSeq = const Value.absent(),
                Value<String?> latestId = const Value.absent(),
                Value<int> latestLamport = const Value.absent(),
                Value<int?> revokedAfterSeq = const Value.absent(),
                Value<int> purpose = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion(
                feedId: feedId,
                rootId: rootId,
                latestSeq: latestSeq,
                latestId: latestId,
                latestLamport: latestLamport,
                revokedAfterSeq: revokedAfterSeq,
                purpose: purpose,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedId,
                required String rootId,
                Value<int> latestSeq = const Value.absent(),
                Value<String?> latestId = const Value.absent(),
                Value<int> latestLamport = const Value.absent(),
                Value<int?> revokedAfterSeq = const Value.absent(),
                Value<int> purpose = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion.insert(
                feedId: feedId,
                rootId: rootId,
                latestSeq: latestSeq,
                latestId: latestId,
                latestLamport: latestLamport,
                revokedAfterSeq: revokedAfterSeq,
                purpose: purpose,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedsTable, FeedRow>(table),
                  BaseReferences<_$JaalDatabase, $FeedsTable, FeedRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $FeedsTable,
      FeedRow,
      $$FeedsTableFilterComposer,
      $$FeedsTableOrderingComposer,
      $$FeedsTableAnnotationComposer,
      $$FeedsTableCreateCompanionBuilder,
      $$FeedsTableUpdateCompanionBuilder,
      (FeedRow, BaseReferences<_$JaalDatabase, $FeedsTable, FeedRow>),
      FeedRow,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String feedId,
  required int seq,
  required String rootId,
  required int lamport,
  required int ts,
  required String type,
  required String raw,
  Value<String?> body,
  Value<int> hops,
  required int firstSeenAt,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> feedId,
  Value<int> seq,
  Value<String> rootId,
  Value<int> lamport,
  Value<int> ts,
  Value<String> type,
  Value<String> raw,
  Value<String?> body,
  Value<int> hops,
  Value<int> firstSeenAt,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$JaalDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$JaalDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get hops =>
      $composableBuilder(column: $table.hops, builder: (column) => column);

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$JaalDatabase, $EventsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$JaalDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<int> hops = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                feedId: feedId,
                seq: seq,
                rootId: rootId,
                lamport: lamport,
                ts: ts,
                type: type,
                raw: raw,
                body: body,
                hops: hops,
                firstSeenAt: firstSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String feedId,
                required int seq,
                required String rootId,
                required int lamport,
                required int ts,
                required String type,
                required String raw,
                Value<String?> body = const Value.absent(),
                Value<int> hops = const Value.absent(),
                required int firstSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                feedId: feedId,
                seq: seq,
                rootId: rootId,
                lamport: lamport,
                ts: ts,
                type: type,
                raw: raw,
                body: body,
                hops: hops,
                firstSeenAt: firstSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, EventRow>(table),
                  BaseReferences<_$JaalDatabase, $EventsTable, EventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$JaalDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String rootId,
  required String name,
  required String handle,
  Value<String> bio,
  required String dmKey,
  Value<String?> avatar,
  required int lamport,
  required String eventId,
  Value<String> handleSkel,
  Value<String> nameSkel,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> rootId,
  Value<String> name,
  Value<String> handle,
  Value<String> bio,
  Value<String> dmKey,
  Value<String?> avatar,
  Value<int> lamport,
  Value<String> eventId,
  Value<String> handleSkel,
  Value<String> nameSkel,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$JaalDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dmKey => $composableBuilder(
    column: $table.dmKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handleSkel => $composableBuilder(
    column: $table.handleSkel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSkel => $composableBuilder(
    column: $table.nameSkel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$JaalDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dmKey => $composableBuilder(
    column: $table.dmKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handleSkel => $composableBuilder(
    column: $table.handleSkel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSkel => $composableBuilder(
    column: $table.nameSkel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get dmKey =>
      $composableBuilder(column: $table.dmKey, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get handleSkel => $composableBuilder(
    column: $table.handleSkel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameSkel =>
      $composableBuilder(column: $table.nameSkel, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$JaalDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$JaalDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String> dmKey = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> handleSkel = const Value.absent(),
                Value<String> nameSkel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                rootId: rootId,
                name: name,
                handle: handle,
                bio: bio,
                dmKey: dmKey,
                avatar: avatar,
                lamport: lamport,
                eventId: eventId,
                handleSkel: handleSkel,
                nameSkel: nameSkel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required String name,
                required String handle,
                Value<String> bio = const Value.absent(),
                required String dmKey,
                Value<String?> avatar = const Value.absent(),
                required int lamport,
                required String eventId,
                Value<String> handleSkel = const Value.absent(),
                Value<String> nameSkel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                rootId: rootId,
                name: name,
                handle: handle,
                bio: bio,
                dmKey: dmKey,
                avatar: avatar,
                lamport: lamport,
                eventId: eventId,
                handleSkel: handleSkel,
                nameSkel: nameSkel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$JaalDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$JaalDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  required String id,
  required String rootId,
  required String feedId,
  required String body,
  Value<String> media,
  required int ts,
  required int lamport,
  Value<int> editLamport,
  Value<String?> editId,
  Value<int> hops,
  required int firstSeenAt,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<String> id,
  Value<String> rootId,
  Value<String> feedId,
  Value<String> body,
  Value<String> media,
  Value<int> ts,
  Value<int> lamport,
  Value<int> editLamport,
  Value<String?> editId,
  Value<int> hops,
  Value<int> firstSeenAt,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$PostsTableFilterComposer extends Composer<_$JaalDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
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

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editLamport => $composableBuilder(
    column: $table.editLamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editId => $composableBuilder(
    column: $table.editId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostsTableOrderingComposer
    extends Composer<_$JaalDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
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

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editLamport => $composableBuilder(
    column: $table.editLamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editId => $composableBuilder(
    column: $table.editId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get media =>
      $composableBuilder(column: $table.media, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<int> get editLamport => $composableBuilder(
    column: $table.editLamport,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editId =>
      $composableBuilder(column: $table.editId, builder: (column) => column);

  GeneratedColumn<int> get hops =>
      $composableBuilder(column: $table.hops, builder: (column) => column);

  GeneratedColumn<int> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $PostsTable,
          PostRow,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (PostRow, BaseReferences<_$JaalDatabase, $PostsTable, PostRow>),
          PostRow,
          PrefetchHooks Function()
        > {
  $$PostsTableTableManager(_$JaalDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> media = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<int> editLamport = const Value.absent(),
                Value<String?> editId = const Value.absent(),
                Value<int> hops = const Value.absent(),
                Value<int> firstSeenAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                rootId: rootId,
                feedId: feedId,
                body: body,
                media: media,
                ts: ts,
                lamport: lamport,
                editLamport: editLamport,
                editId: editId,
                hops: hops,
                firstSeenAt: firstSeenAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rootId,
                required String feedId,
                required String body,
                Value<String> media = const Value.absent(),
                required int ts,
                required int lamport,
                Value<int> editLamport = const Value.absent(),
                Value<String?> editId = const Value.absent(),
                Value<int> hops = const Value.absent(),
                required int firstSeenAt,
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                rootId: rootId,
                feedId: feedId,
                body: body,
                media: media,
                ts: ts,
                lamport: lamport,
                editLamport: editLamport,
                editId: editId,
                hops: hops,
                firstSeenAt: firstSeenAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostsTable, PostRow>(table),
                  BaseReferences<_$JaalDatabase, $PostsTable, PostRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $PostsTable,
      PostRow,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (PostRow, BaseReferences<_$JaalDatabase, $PostsTable, PostRow>),
      PostRow,
      PrefetchHooks Function()
    >;
typedef $$ReactionsTableCreateCompanionBuilder = ReactionsCompanion Function({
  required String rootId,
  required String target,
  Value<String?> sticker,
  required int x,
  required int y,
  required int rot,
  required int lamport,
  required String eventId,
  Value<int> rowid,
});
typedef $$ReactionsTableUpdateCompanionBuilder = ReactionsCompanion Function({
  Value<String> rootId,
  Value<String> target,
  Value<String?> sticker,
  Value<int> x,
  Value<int> y,
  Value<int> rot,
  Value<int> lamport,
  Value<String> eventId,
  Value<int> rowid,
});

class $$ReactionsTableFilterComposer
    extends Composer<_$JaalDatabase, $ReactionsTable> {
  $$ReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sticker => $composableBuilder(
    column: $table.sticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rot => $composableBuilder(
    column: $table.rot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionsTableOrderingComposer
    extends Composer<_$JaalDatabase, $ReactionsTable> {
  $$ReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sticker => $composableBuilder(
    column: $table.sticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rot => $composableBuilder(
    column: $table.rot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ReactionsTable> {
  $$ReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get sticker =>
      $composableBuilder(column: $table.sticker, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<int> get rot =>
      $composableBuilder(column: $table.rot, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);
}

class $$ReactionsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ReactionsTable,
          ReactionRow,
          $$ReactionsTableFilterComposer,
          $$ReactionsTableOrderingComposer,
          $$ReactionsTableAnnotationComposer,
          $$ReactionsTableCreateCompanionBuilder,
          $$ReactionsTableUpdateCompanionBuilder,
          (
            ReactionRow,
            BaseReferences<_$JaalDatabase, $ReactionsTable, ReactionRow>,
          ),
          ReactionRow,
          PrefetchHooks Function()
        > {
  $$ReactionsTableTableManager(_$JaalDatabase db, $ReactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String?> sticker = const Value.absent(),
                Value<int> x = const Value.absent(),
                Value<int> y = const Value.absent(),
                Value<int> rot = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion(
                rootId: rootId,
                target: target,
                sticker: sticker,
                x: x,
                y: y,
                rot: rot,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required String target,
                Value<String?> sticker = const Value.absent(),
                required int x,
                required int y,
                required int rot,
                required int lamport,
                required String eventId,
                Value<int> rowid = const Value.absent(),
              }) => ReactionsCompanion.insert(
                rootId: rootId,
                target: target,
                sticker: sticker,
                x: x,
                y: y,
                rot: rot,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReactionsTable, ReactionRow>(table),
                  BaseReferences<_$JaalDatabase, $ReactionsTable, ReactionRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ReactionsTable,
      ReactionRow,
      $$ReactionsTableFilterComposer,
      $$ReactionsTableOrderingComposer,
      $$ReactionsTableAnnotationComposer,
      $$ReactionsTableCreateCompanionBuilder,
      $$ReactionsTableUpdateCompanionBuilder,
      (
        ReactionRow,
        BaseReferences<_$JaalDatabase, $ReactionsTable, ReactionRow>,
      ),
      ReactionRow,
      PrefetchHooks Function()
    >;
typedef $$CommentsTableCreateCompanionBuilder = CommentsCompanion Function({
  required String id,
  required String target,
  required String rootId,
  required String body,
  Value<String?> parent,
  required int ts,
  required int lamport,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$CommentsTableUpdateCompanionBuilder = CommentsCompanion Function({
  Value<String> id,
  Value<String> target,
  Value<String> rootId,
  Value<String> body,
  Value<String?> parent,
  Value<int> ts,
  Value<int> lamport,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$CommentsTableFilterComposer
    extends Composer<_$JaalDatabase, $CommentsTable> {
  $$CommentsTableFilterComposer({
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

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parent => $composableBuilder(
    column: $table.parent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommentsTableOrderingComposer
    extends Composer<_$JaalDatabase, $CommentsTable> {
  $$CommentsTableOrderingComposer({
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

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parent => $composableBuilder(
    column: $table.parent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $CommentsTable> {
  $$CommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get parent =>
      $composableBuilder(column: $table.parent, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$CommentsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $CommentsTable,
          CommentRow,
          $$CommentsTableFilterComposer,
          $$CommentsTableOrderingComposer,
          $$CommentsTableAnnotationComposer,
          $$CommentsTableCreateCompanionBuilder,
          $$CommentsTableUpdateCompanionBuilder,
          (
            CommentRow,
            BaseReferences<_$JaalDatabase, $CommentsTable, CommentRow>,
          ),
          CommentRow,
          PrefetchHooks Function()
        > {
  $$CommentsTableTableManager(_$JaalDatabase db, $CommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> parent = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion(
                id: id,
                target: target,
                rootId: rootId,
                body: body,
                parent: parent,
                ts: ts,
                lamport: lamport,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String target,
                required String rootId,
                required String body,
                Value<String?> parent = const Value.absent(),
                required int ts,
                required int lamport,
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion.insert(
                id: id,
                target: target,
                rootId: rootId,
                body: body,
                parent: parent,
                ts: ts,
                lamport: lamport,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CommentsTable, CommentRow>(table),
                  BaseReferences<_$JaalDatabase, $CommentsTable, CommentRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $CommentsTable,
      CommentRow,
      $$CommentsTableFilterComposer,
      $$CommentsTableOrderingComposer,
      $$CommentsTableAnnotationComposer,
      $$CommentsTableCreateCompanionBuilder,
      $$CommentsTableUpdateCompanionBuilder,
      (CommentRow, BaseReferences<_$JaalDatabase, $CommentsTable, CommentRow>),
      CommentRow,
      PrefetchHooks Function()
    >;
typedef $$FollowsTableCreateCompanionBuilder = FollowsCompanion Function({
  required String rootId,
  required String target,
  required bool isOn,
  required int lamport,
  required String eventId,
  Value<int> rowid,
});
typedef $$FollowsTableUpdateCompanionBuilder = FollowsCompanion Function({
  Value<String> rootId,
  Value<String> target,
  Value<bool> isOn,
  Value<int> lamport,
  Value<String> eventId,
  Value<int> rowid,
});

class $$FollowsTableFilterComposer
    extends Composer<_$JaalDatabase, $FollowsTable> {
  $$FollowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOn => $composableBuilder(
    column: $table.isOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FollowsTableOrderingComposer
    extends Composer<_$JaalDatabase, $FollowsTable> {
  $$FollowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOn => $composableBuilder(
    column: $table.isOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FollowsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $FollowsTable> {
  $$FollowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get isOn =>
      $composableBuilder(column: $table.isOn, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);
}

class $$FollowsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $FollowsTable,
          FollowRow,
          $$FollowsTableFilterComposer,
          $$FollowsTableOrderingComposer,
          $$FollowsTableAnnotationComposer,
          $$FollowsTableCreateCompanionBuilder,
          $$FollowsTableUpdateCompanionBuilder,
          (FollowRow, BaseReferences<_$JaalDatabase, $FollowsTable, FollowRow>),
          FollowRow,
          PrefetchHooks Function()
        > {
  $$FollowsTableTableManager(_$JaalDatabase db, $FollowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<bool> isOn = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FollowsCompanion(
                rootId: rootId,
                target: target,
                isOn: isOn,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required String target,
                required bool isOn,
                required int lamport,
                required String eventId,
                Value<int> rowid = const Value.absent(),
              }) => FollowsCompanion.insert(
                rootId: rootId,
                target: target,
                isOn: isOn,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FollowsTable, FollowRow>(table),
                  BaseReferences<_$JaalDatabase, $FollowsTable, FollowRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FollowsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $FollowsTable,
      FollowRow,
      $$FollowsTableFilterComposer,
      $$FollowsTableOrderingComposer,
      $$FollowsTableAnnotationComposer,
      $$FollowsTableCreateCompanionBuilder,
      $$FollowsTableUpdateCompanionBuilder,
      (FollowRow, BaseReferences<_$JaalDatabase, $FollowsTable, FollowRow>),
      FollowRow,
      PrefetchHooks Function()
    >;
typedef $$TombstonesTableCreateCompanionBuilder = TombstonesCompanion Function({
  required String target,
  required String byRoot,
  required int lamport,
  required String eventId,
  Value<int> rowid,
});
typedef $$TombstonesTableUpdateCompanionBuilder = TombstonesCompanion Function({
  Value<String> target,
  Value<String> byRoot,
  Value<int> lamport,
  Value<String> eventId,
  Value<int> rowid,
});

class $$TombstonesTableFilterComposer
    extends Composer<_$JaalDatabase, $TombstonesTable> {
  $$TombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get byRoot => $composableBuilder(
    column: $table.byRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TombstonesTableOrderingComposer
    extends Composer<_$JaalDatabase, $TombstonesTable> {
  $$TombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get byRoot => $composableBuilder(
    column: $table.byRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TombstonesTableAnnotationComposer
    extends Composer<_$JaalDatabase, $TombstonesTable> {
  $$TombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get byRoot =>
      $composableBuilder(column: $table.byRoot, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);
}

class $$TombstonesTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $TombstonesTable,
          TombstoneRow,
          $$TombstonesTableFilterComposer,
          $$TombstonesTableOrderingComposer,
          $$TombstonesTableAnnotationComposer,
          $$TombstonesTableCreateCompanionBuilder,
          $$TombstonesTableUpdateCompanionBuilder,
          (
            TombstoneRow,
            BaseReferences<_$JaalDatabase, $TombstonesTable, TombstoneRow>,
          ),
          TombstoneRow,
          PrefetchHooks Function()
        > {
  $$TombstonesTableTableManager(_$JaalDatabase db, $TombstonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> target = const Value.absent(),
                Value<String> byRoot = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TombstonesCompanion(
                target: target,
                byRoot: byRoot,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String target,
                required String byRoot,
                required int lamport,
                required String eventId,
                Value<int> rowid = const Value.absent(),
              }) => TombstonesCompanion.insert(
                target: target,
                byRoot: byRoot,
                lamport: lamport,
                eventId: eventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TombstonesTable, TombstoneRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $TombstonesTable,
                    TombstoneRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $TombstonesTable,
      TombstoneRow,
      $$TombstonesTableFilterComposer,
      $$TombstonesTableOrderingComposer,
      $$TombstonesTableAnnotationComposer,
      $$TombstonesTableCreateCompanionBuilder,
      $$TombstonesTableUpdateCompanionBuilder,
      (
        TombstoneRow,
        BaseReferences<_$JaalDatabase, $TombstonesTable, TombstoneRow>,
      ),
      TombstoneRow,
      PrefetchHooks Function()
    >;
typedef $$EnvelopesTableCreateCompanionBuilder = EnvelopesCompanion Function({
  required String id,
  required String raw,
  required String hint,
  required String ackHash,
  required int exp,
  required int size,
  required int receivedAt,
  Value<int> hops,
  required int origin,
  Value<bool> acked,
  Value<int> rowid,
});
typedef $$EnvelopesTableUpdateCompanionBuilder = EnvelopesCompanion Function({
  Value<String> id,
  Value<String> raw,
  Value<String> hint,
  Value<String> ackHash,
  Value<int> exp,
  Value<int> size,
  Value<int> receivedAt,
  Value<int> hops,
  Value<int> origin,
  Value<bool> acked,
  Value<int> rowid,
});

class $$EnvelopesTableFilterComposer
    extends Composer<_$JaalDatabase, $EnvelopesTable> {
  $$EnvelopesTableFilterComposer({
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

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hint => $composableBuilder(
    column: $table.hint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acked => $composableBuilder(
    column: $table.acked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnvelopesTableOrderingComposer
    extends Composer<_$JaalDatabase, $EnvelopesTable> {
  $$EnvelopesTableOrderingComposer({
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

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hint => $composableBuilder(
    column: $table.hint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acked => $composableBuilder(
    column: $table.acked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvelopesTableAnnotationComposer
    extends Composer<_$JaalDatabase, $EnvelopesTable> {
  $$EnvelopesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<String> get ackHash =>
      $composableBuilder(column: $table.ackHash, builder: (column) => column);

  GeneratedColumn<int> get exp =>
      $composableBuilder(column: $table.exp, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hops =>
      $composableBuilder(column: $table.hops, builder: (column) => column);

  GeneratedColumn<int> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<bool> get acked =>
      $composableBuilder(column: $table.acked, builder: (column) => column);
}

class $$EnvelopesTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $EnvelopesTable,
          EnvelopeRow,
          $$EnvelopesTableFilterComposer,
          $$EnvelopesTableOrderingComposer,
          $$EnvelopesTableAnnotationComposer,
          $$EnvelopesTableCreateCompanionBuilder,
          $$EnvelopesTableUpdateCompanionBuilder,
          (
            EnvelopeRow,
            BaseReferences<_$JaalDatabase, $EnvelopesTable, EnvelopeRow>,
          ),
          EnvelopeRow,
          PrefetchHooks Function()
        > {
  $$EnvelopesTableTableManager(_$JaalDatabase db, $EnvelopesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvelopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvelopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvelopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<String> hint = const Value.absent(),
                Value<String> ackHash = const Value.absent(),
                Value<int> exp = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<int> hops = const Value.absent(),
                Value<int> origin = const Value.absent(),
                Value<bool> acked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvelopesCompanion(
                id: id,
                raw: raw,
                hint: hint,
                ackHash: ackHash,
                exp: exp,
                size: size,
                receivedAt: receivedAt,
                hops: hops,
                origin: origin,
                acked: acked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String raw,
                required String hint,
                required String ackHash,
                required int exp,
                required int size,
                required int receivedAt,
                Value<int> hops = const Value.absent(),
                required int origin,
                Value<bool> acked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvelopesCompanion.insert(
                id: id,
                raw: raw,
                hint: hint,
                ackHash: ackHash,
                exp: exp,
                size: size,
                receivedAt: receivedAt,
                hops: hops,
                origin: origin,
                acked: acked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnvelopesTable, EnvelopeRow>(table),
                  BaseReferences<_$JaalDatabase, $EnvelopesTable, EnvelopeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnvelopesTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $EnvelopesTable,
      EnvelopeRow,
      $$EnvelopesTableFilterComposer,
      $$EnvelopesTableOrderingComposer,
      $$EnvelopesTableAnnotationComposer,
      $$EnvelopesTableCreateCompanionBuilder,
      $$EnvelopesTableUpdateCompanionBuilder,
      (
        EnvelopeRow,
        BaseReferences<_$JaalDatabase, $EnvelopesTable, EnvelopeRow>,
      ),
      EnvelopeRow,
      PrefetchHooks Function()
    >;
typedef $$AcksTableCreateCompanionBuilder = AcksCompanion Function({
  required String ackHash,
  required String secret,
  required int exp,
  Value<int> rowid,
});
typedef $$AcksTableUpdateCompanionBuilder = AcksCompanion Function({
  Value<String> ackHash,
  Value<String> secret,
  Value<int> exp,
  Value<int> rowid,
});

class $$AcksTableFilterComposer extends Composer<_$JaalDatabase, $AcksTable> {
  $$AcksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AcksTableOrderingComposer extends Composer<_$JaalDatabase, $AcksTable> {
  $$AcksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secret => $composableBuilder(
    column: $table.secret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exp => $composableBuilder(
    column: $table.exp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcksTableAnnotationComposer
    extends Composer<_$JaalDatabase, $AcksTable> {
  $$AcksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ackHash =>
      $composableBuilder(column: $table.ackHash, builder: (column) => column);

  GeneratedColumn<String> get secret =>
      $composableBuilder(column: $table.secret, builder: (column) => column);

  GeneratedColumn<int> get exp =>
      $composableBuilder(column: $table.exp, builder: (column) => column);
}

class $$AcksTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $AcksTable,
          AckRow,
          $$AcksTableFilterComposer,
          $$AcksTableOrderingComposer,
          $$AcksTableAnnotationComposer,
          $$AcksTableCreateCompanionBuilder,
          $$AcksTableUpdateCompanionBuilder,
          (AckRow, BaseReferences<_$JaalDatabase, $AcksTable, AckRow>),
          AckRow,
          PrefetchHooks Function()
        > {
  $$AcksTableTableManager(_$JaalDatabase db, $AcksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ackHash = const Value.absent(),
                Value<String> secret = const Value.absent(),
                Value<int> exp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AcksCompanion(
                ackHash: ackHash,
                secret: secret,
                exp: exp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ackHash,
                required String secret,
                required int exp,
                Value<int> rowid = const Value.absent(),
              }) => AcksCompanion.insert(
                ackHash: ackHash,
                secret: secret,
                exp: exp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AcksTable, AckRow>(table),
                  BaseReferences<_$JaalDatabase, $AcksTable, AckRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AcksTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $AcksTable,
      AckRow,
      $$AcksTableFilterComposer,
      $$AcksTableOrderingComposer,
      $$AcksTableAnnotationComposer,
      $$AcksTableCreateCompanionBuilder,
      $$AcksTableUpdateCompanionBuilder,
      (AckRow, BaseReferences<_$JaalDatabase, $AcksTable, AckRow>),
      AckRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String peerRoot,
  required bool outgoing,
  required String body,
  required int sentAt,
  Value<int?> receivedAt,
  required String ackHash,
  Value<bool> delivered,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> peerRoot,
  Value<bool> outgoing,
  Value<String> body,
  Value<int> sentAt,
  Value<int?> receivedAt,
  Value<String> ackHash,
  Value<bool> delivered,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$JaalDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<String> get peerRoot => $composableBuilder(
    column: $table.peerRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get outgoing => $composableBuilder(
    column: $table.outgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$JaalDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<String> get peerRoot => $composableBuilder(
    column: $table.peerRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get outgoing => $composableBuilder(
    column: $table.outgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ackHash => $composableBuilder(
    column: $table.ackHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$JaalDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get peerRoot =>
      $composableBuilder(column: $table.peerRoot, builder: (column) => column);

  GeneratedColumn<bool> get outgoing =>
      $composableBuilder(column: $table.outgoing, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ackHash =>
      $composableBuilder(column: $table.ackHash, builder: (column) => column);

  GeneratedColumn<bool> get delivered =>
      $composableBuilder(column: $table.delivered, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$JaalDatabase, $MessagesTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$JaalDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> peerRoot = const Value.absent(),
                Value<bool> outgoing = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> sentAt = const Value.absent(),
                Value<int?> receivedAt = const Value.absent(),
                Value<String> ackHash = const Value.absent(),
                Value<bool> delivered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                peerRoot: peerRoot,
                outgoing: outgoing,
                body: body,
                sentAt: sentAt,
                receivedAt: receivedAt,
                ackHash: ackHash,
                delivered: delivered,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String peerRoot,
                required bool outgoing,
                required String body,
                required int sentAt,
                Value<int?> receivedAt = const Value.absent(),
                required String ackHash,
                Value<bool> delivered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                peerRoot: peerRoot,
                outgoing: outgoing,
                body: body,
                sentAt: sentAt,
                receivedAt: receivedAt,
                ackHash: ackHash,
                delivered: delivered,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  BaseReferences<_$JaalDatabase, $MessagesTable, MessageRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$JaalDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$BlocksTableCreateCompanionBuilder = BlocksCompanion Function({
  required String rootId,
  required int since,
  Value<int> rowid,
});
typedef $$BlocksTableUpdateCompanionBuilder = BlocksCompanion Function({
  Value<String> rootId,
  Value<int> since,
  Value<int> rowid,
});

class $$BlocksTableFilterComposer
    extends Composer<_$JaalDatabase, $BlocksTable> {
  $$BlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get since => $composableBuilder(
    column: $table.since,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlocksTableOrderingComposer
    extends Composer<_$JaalDatabase, $BlocksTable> {
  $$BlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get since => $composableBuilder(
    column: $table.since,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlocksTableAnnotationComposer
    extends Composer<_$JaalDatabase, $BlocksTable> {
  $$BlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get since =>
      $composableBuilder(column: $table.since, builder: (column) => column);
}

class $$BlocksTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $BlocksTable,
          BlockRow,
          $$BlocksTableFilterComposer,
          $$BlocksTableOrderingComposer,
          $$BlocksTableAnnotationComposer,
          $$BlocksTableCreateCompanionBuilder,
          $$BlocksTableUpdateCompanionBuilder,
          (BlockRow, BaseReferences<_$JaalDatabase, $BlocksTable, BlockRow>),
          BlockRow,
          PrefetchHooks Function()
        > {
  $$BlocksTableTableManager(_$JaalDatabase db, $BlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> rootId = const Value.absent(),
            Value<int> since = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => BlocksCompanion(rootId: rootId, since: since, rowid: rowid),
          createCompanionCallback:
              ({
                required String rootId,
                required int since,
                Value<int> rowid = const Value.absent(),
              }) => BlocksCompanion.insert(
                rootId: rootId,
                since: since,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BlocksTable, BlockRow>(table),
                  BaseReferences<_$JaalDatabase, $BlocksTable, BlockRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $BlocksTable,
      BlockRow,
      $$BlocksTableFilterComposer,
      $$BlocksTableOrderingComposer,
      $$BlocksTableAnnotationComposer,
      $$BlocksTableCreateCompanionBuilder,
      $$BlocksTableUpdateCompanionBuilder,
      (BlockRow, BaseReferences<_$JaalDatabase, $BlocksTable, BlockRow>),
      BlockRow,
      PrefetchHooks Function()
    >;
typedef $$PeersSeenTableCreateCompanionBuilder = PeersSeenCompanion Function({
  required String feedId,
  required String rootId,
  required int lastSeen,
  Value<int> encounters,
  Value<int> rowid,
});
typedef $$PeersSeenTableUpdateCompanionBuilder = PeersSeenCompanion Function({
  Value<String> feedId,
  Value<String> rootId,
  Value<int> lastSeen,
  Value<int> encounters,
  Value<int> rowid,
});

class $$PeersSeenTableFilterComposer
    extends Composer<_$JaalDatabase, $PeersSeenTable> {
  $$PeersSeenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get encounters => $composableBuilder(
    column: $table.encounters,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeersSeenTableOrderingComposer
    extends Composer<_$JaalDatabase, $PeersSeenTable> {
  $$PeersSeenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get encounters => $composableBuilder(
    column: $table.encounters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeersSeenTableAnnotationComposer
    extends Composer<_$JaalDatabase, $PeersSeenTable> {
  $$PeersSeenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get encounters => $composableBuilder(
    column: $table.encounters,
    builder: (column) => column,
  );
}

class $$PeersSeenTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $PeersSeenTable,
          PeerSeenRow,
          $$PeersSeenTableFilterComposer,
          $$PeersSeenTableOrderingComposer,
          $$PeersSeenTableAnnotationComposer,
          $$PeersSeenTableCreateCompanionBuilder,
          $$PeersSeenTableUpdateCompanionBuilder,
          (
            PeerSeenRow,
            BaseReferences<_$JaalDatabase, $PeersSeenTable, PeerSeenRow>,
          ),
          PeerSeenRow,
          PrefetchHooks Function()
        > {
  $$PeersSeenTableTableManager(_$JaalDatabase db, $PeersSeenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeersSeenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeersSeenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeersSeenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<int> encounters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeersSeenCompanion(
                feedId: feedId,
                rootId: rootId,
                lastSeen: lastSeen,
                encounters: encounters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedId,
                required String rootId,
                required int lastSeen,
                Value<int> encounters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeersSeenCompanion.insert(
                feedId: feedId,
                rootId: rootId,
                lastSeen: lastSeen,
                encounters: encounters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeersSeenTable, PeerSeenRow>(table),
                  BaseReferences<_$JaalDatabase, $PeersSeenTable, PeerSeenRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeersSeenTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $PeersSeenTable,
      PeerSeenRow,
      $$PeersSeenTableFilterComposer,
      $$PeersSeenTableOrderingComposer,
      $$PeersSeenTableAnnotationComposer,
      $$PeersSeenTableCreateCompanionBuilder,
      $$PeersSeenTableUpdateCompanionBuilder,
      (
        PeerSeenRow,
        BaseReferences<_$JaalDatabase, $PeersSeenTable, PeerSeenRow>,
      ),
      PeerSeenRow,
      PrefetchHooks Function()
    >;
typedef $$StatsTableCreateCompanionBuilder = StatsCompanion Function({
  required String key,
  required int value,
  Value<int> rowid,
});
typedef $$StatsTableUpdateCompanionBuilder = StatsCompanion Function({
  Value<String> key,
  Value<int> value,
  Value<int> rowid,
});

class $$StatsTableFilterComposer extends Composer<_$JaalDatabase, $StatsTable> {
  $$StatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsTableOrderingComposer
    extends Composer<_$JaalDatabase, $StatsTable> {
  $$StatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $StatsTable> {
  $$StatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$StatsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $StatsTable,
          StatRow,
          $$StatsTableFilterComposer,
          $$StatsTableOrderingComposer,
          $$StatsTableAnnotationComposer,
          $$StatsTableCreateCompanionBuilder,
          $$StatsTableUpdateCompanionBuilder,
          (StatRow, BaseReferences<_$JaalDatabase, $StatsTable, StatRow>),
          StatRow,
          PrefetchHooks Function()
        > {
  $$StatsTableTableManager(_$JaalDatabase db, $StatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<int> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StatsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required int value,
            Value<int> rowid = const Value.absent(),
          }) => StatsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatsTable, StatRow>(table),
                  BaseReferences<_$JaalDatabase, $StatsTable, StatRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $StatsTable,
      StatRow,
      $$StatsTableFilterComposer,
      $$StatsTableOrderingComposer,
      $$StatsTableAnnotationComposer,
      $$StatsTableCreateCompanionBuilder,
      $$StatsTableUpdateCompanionBuilder,
      (StatRow, BaseReferences<_$JaalDatabase, $StatsTable, StatRow>),
      StatRow,
      PrefetchHooks Function()
    >;
typedef $$ModActionsTableCreateCompanionBuilder = ModActionsCompanion Function({
  required String eventId,
  required String author,
  required String feedId,
  required int seq,
  required String type,
  required String target,
  Value<bool> isOn,
  required int lamport,
  required int ts,
  required String body,
  required bool valid,
  Value<int> rowid,
});
typedef $$ModActionsTableUpdateCompanionBuilder = ModActionsCompanion Function({
  Value<String> eventId,
  Value<String> author,
  Value<String> feedId,
  Value<int> seq,
  Value<String> type,
  Value<String> target,
  Value<bool> isOn,
  Value<int> lamport,
  Value<int> ts,
  Value<String> body,
  Value<bool> valid,
  Value<int> rowid,
});

class $$ModActionsTableFilterComposer
    extends Composer<_$JaalDatabase, $ModActionsTable> {
  $$ModActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOn => $composableBuilder(
    column: $table.isOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get valid => $composableBuilder(
    column: $table.valid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModActionsTableOrderingComposer
    extends Composer<_$JaalDatabase, $ModActionsTable> {
  $$ModActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOn => $composableBuilder(
    column: $table.isOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lamport => $composableBuilder(
    column: $table.lamport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get valid => $composableBuilder(
    column: $table.valid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModActionsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ModActionsTable> {
  $$ModActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get isOn =>
      $composableBuilder(column: $table.isOn, builder: (column) => column);

  GeneratedColumn<int> get lamport =>
      $composableBuilder(column: $table.lamport, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get valid =>
      $composableBuilder(column: $table.valid, builder: (column) => column);
}

class $$ModActionsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ModActionsTable,
          ModActionRow,
          $$ModActionsTableFilterComposer,
          $$ModActionsTableOrderingComposer,
          $$ModActionsTableAnnotationComposer,
          $$ModActionsTableCreateCompanionBuilder,
          $$ModActionsTableUpdateCompanionBuilder,
          (
            ModActionRow,
            BaseReferences<_$JaalDatabase, $ModActionsTable, ModActionRow>,
          ),
          ModActionRow,
          PrefetchHooks Function()
        > {
  $$ModActionsTableTableManager(_$JaalDatabase db, $ModActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<bool> isOn = const Value.absent(),
                Value<int> lamport = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> valid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModActionsCompanion(
                eventId: eventId,
                author: author,
                feedId: feedId,
                seq: seq,
                type: type,
                target: target,
                isOn: isOn,
                lamport: lamport,
                ts: ts,
                body: body,
                valid: valid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String author,
                required String feedId,
                required int seq,
                required String type,
                required String target,
                Value<bool> isOn = const Value.absent(),
                required int lamport,
                required int ts,
                required String body,
                required bool valid,
                Value<int> rowid = const Value.absent(),
              }) => ModActionsCompanion.insert(
                eventId: eventId,
                author: author,
                feedId: feedId,
                seq: seq,
                type: type,
                target: target,
                isOn: isOn,
                lamport: lamport,
                ts: ts,
                body: body,
                valid: valid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModActionsTable, ModActionRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $ModActionsTable,
                    ModActionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ModActionsTable,
      ModActionRow,
      $$ModActionsTableFilterComposer,
      $$ModActionsTableOrderingComposer,
      $$ModActionsTableAnnotationComposer,
      $$ModActionsTableCreateCompanionBuilder,
      $$ModActionsTableUpdateCompanionBuilder,
      (
        ModActionRow,
        BaseReferences<_$JaalDatabase, $ModActionsTable, ModActionRow>,
      ),
      ModActionRow,
      PrefetchHooks Function()
    >;
typedef $$ModeratorsTableCreateCompanionBuilder = ModeratorsCompanion Function({
  required String rootId,
  required int role,
  Value<String> vouchedBy,
  Value<int> rowid,
});
typedef $$ModeratorsTableUpdateCompanionBuilder = ModeratorsCompanion Function({
  Value<String> rootId,
  Value<int> role,
  Value<String> vouchedBy,
  Value<int> rowid,
});

class $$ModeratorsTableFilterComposer
    extends Composer<_$JaalDatabase, $ModeratorsTable> {
  $$ModeratorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vouchedBy => $composableBuilder(
    column: $table.vouchedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModeratorsTableOrderingComposer
    extends Composer<_$JaalDatabase, $ModeratorsTable> {
  $$ModeratorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vouchedBy => $composableBuilder(
    column: $table.vouchedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModeratorsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ModeratorsTable> {
  $$ModeratorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get vouchedBy =>
      $composableBuilder(column: $table.vouchedBy, builder: (column) => column);
}

class $$ModeratorsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ModeratorsTable,
          ModeratorRow,
          $$ModeratorsTableFilterComposer,
          $$ModeratorsTableOrderingComposer,
          $$ModeratorsTableAnnotationComposer,
          $$ModeratorsTableCreateCompanionBuilder,
          $$ModeratorsTableUpdateCompanionBuilder,
          (
            ModeratorRow,
            BaseReferences<_$JaalDatabase, $ModeratorsTable, ModeratorRow>,
          ),
          ModeratorRow,
          PrefetchHooks Function()
        > {
  $$ModeratorsTableTableManager(_$JaalDatabase db, $ModeratorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModeratorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModeratorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModeratorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<String> vouchedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModeratorsCompanion(
                rootId: rootId,
                role: role,
                vouchedBy: vouchedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required int role,
                Value<String> vouchedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModeratorsCompanion.insert(
                rootId: rootId,
                role: role,
                vouchedBy: vouchedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModeratorsTable, ModeratorRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $ModeratorsTable,
                    ModeratorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModeratorsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ModeratorsTable,
      ModeratorRow,
      $$ModeratorsTableFilterComposer,
      $$ModeratorsTableOrderingComposer,
      $$ModeratorsTableAnnotationComposer,
      $$ModeratorsTableCreateCompanionBuilder,
      $$ModeratorsTableUpdateCompanionBuilder,
      (
        ModeratorRow,
        BaseReferences<_$JaalDatabase, $ModeratorsTable, ModeratorRow>,
      ),
      ModeratorRow,
      PrefetchHooks Function()
    >;
typedef $$ModStatusTableCreateCompanionBuilder = ModStatusCompanion Function({
  required String rootId,
  required int state,
  required int votes,
  Value<String> reason,
  Value<int> rowid,
});
typedef $$ModStatusTableUpdateCompanionBuilder = ModStatusCompanion Function({
  Value<String> rootId,
  Value<int> state,
  Value<int> votes,
  Value<String> reason,
  Value<int> rowid,
});

class $$ModStatusTableFilterComposer
    extends Composer<_$JaalDatabase, $ModStatusTable> {
  $$ModStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModStatusTableOrderingComposer
    extends Composer<_$JaalDatabase, $ModStatusTable> {
  $$ModStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModStatusTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ModStatusTable> {
  $$ModStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get votes =>
      $composableBuilder(column: $table.votes, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$ModStatusTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ModStatusTable,
          ModStatusRow,
          $$ModStatusTableFilterComposer,
          $$ModStatusTableOrderingComposer,
          $$ModStatusTableAnnotationComposer,
          $$ModStatusTableCreateCompanionBuilder,
          $$ModStatusTableUpdateCompanionBuilder,
          (
            ModStatusRow,
            BaseReferences<_$JaalDatabase, $ModStatusTable, ModStatusRow>,
          ),
          ModStatusRow,
          PrefetchHooks Function()
        > {
  $$ModStatusTableTableManager(_$JaalDatabase db, $ModStatusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<int> votes = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModStatusCompanion(
                rootId: rootId,
                state: state,
                votes: votes,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required int state,
                required int votes,
                Value<String> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModStatusCompanion.insert(
                rootId: rootId,
                state: state,
                votes: votes,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModStatusTable, ModStatusRow>(table),
                  BaseReferences<_$JaalDatabase, $ModStatusTable, ModStatusRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModStatusTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ModStatusTable,
      ModStatusRow,
      $$ModStatusTableFilterComposer,
      $$ModStatusTableOrderingComposer,
      $$ModStatusTableAnnotationComposer,
      $$ModStatusTableCreateCompanionBuilder,
      $$ModStatusTableUpdateCompanionBuilder,
      (
        ModStatusRow,
        BaseReferences<_$JaalDatabase, $ModStatusTable, ModStatusRow>,
      ),
      ModStatusRow,
      PrefetchHooks Function()
    >;
typedef $$ModRevocationsTableCreateCompanionBuilder =
    ModRevocationsCompanion Function({
      required String rootId,
      required String cutoff,
      Value<int> rowid,
    });
typedef $$ModRevocationsTableUpdateCompanionBuilder =
    ModRevocationsCompanion Function({
      Value<String> rootId,
      Value<String> cutoff,
      Value<int> rowid,
    });

class $$ModRevocationsTableFilterComposer
    extends Composer<_$JaalDatabase, $ModRevocationsTable> {
  $$ModRevocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cutoff => $composableBuilder(
    column: $table.cutoff,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModRevocationsTableOrderingComposer
    extends Composer<_$JaalDatabase, $ModRevocationsTable> {
  $$ModRevocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cutoff => $composableBuilder(
    column: $table.cutoff,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModRevocationsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $ModRevocationsTable> {
  $$ModRevocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get cutoff =>
      $composableBuilder(column: $table.cutoff, builder: (column) => column);
}

class $$ModRevocationsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $ModRevocationsTable,
          ModRevocationRow,
          $$ModRevocationsTableFilterComposer,
          $$ModRevocationsTableOrderingComposer,
          $$ModRevocationsTableAnnotationComposer,
          $$ModRevocationsTableCreateCompanionBuilder,
          $$ModRevocationsTableUpdateCompanionBuilder,
          (
            ModRevocationRow,
            BaseReferences<
              _$JaalDatabase,
              $ModRevocationsTable,
              ModRevocationRow
            >,
          ),
          ModRevocationRow,
          PrefetchHooks Function()
        > {
  $$ModRevocationsTableTableManager(
    _$JaalDatabase db,
    $ModRevocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModRevocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModRevocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModRevocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootId = const Value.absent(),
                Value<String> cutoff = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModRevocationsCompanion(
                rootId: rootId,
                cutoff: cutoff,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootId,
                required String cutoff,
                Value<int> rowid = const Value.absent(),
              }) => ModRevocationsCompanion.insert(
                rootId: rootId,
                cutoff: cutoff,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModRevocationsTable, ModRevocationRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $ModRevocationsTable,
                    ModRevocationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModRevocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $ModRevocationsTable,
      ModRevocationRow,
      $$ModRevocationsTableFilterComposer,
      $$ModRevocationsTableOrderingComposer,
      $$ModRevocationsTableAnnotationComposer,
      $$ModRevocationsTableCreateCompanionBuilder,
      $$ModRevocationsTableUpdateCompanionBuilder,
      (
        ModRevocationRow,
        BaseReferences<_$JaalDatabase, $ModRevocationsTable, ModRevocationRow>,
      ),
      ModRevocationRow,
      PrefetchHooks Function()
    >;
typedef $$VerifiedTableCreateCompanionBuilder = VerifiedCompanion Function({
  required String rootId,
  required int at,
  Value<int> rowid,
});
typedef $$VerifiedTableUpdateCompanionBuilder = VerifiedCompanion Function({
  Value<String> rootId,
  Value<int> at,
  Value<int> rowid,
});

class $$VerifiedTableFilterComposer
    extends Composer<_$JaalDatabase, $VerifiedTable> {
  $$VerifiedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerifiedTableOrderingComposer
    extends Composer<_$JaalDatabase, $VerifiedTable> {
  $$VerifiedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerifiedTableAnnotationComposer
    extends Composer<_$JaalDatabase, $VerifiedTable> {
  $$VerifiedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$VerifiedTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $VerifiedTable,
          VerifiedRow,
          $$VerifiedTableFilterComposer,
          $$VerifiedTableOrderingComposer,
          $$VerifiedTableAnnotationComposer,
          $$VerifiedTableCreateCompanionBuilder,
          $$VerifiedTableUpdateCompanionBuilder,
          (
            VerifiedRow,
            BaseReferences<_$JaalDatabase, $VerifiedTable, VerifiedRow>,
          ),
          VerifiedRow,
          PrefetchHooks Function()
        > {
  $$VerifiedTableTableManager(_$JaalDatabase db, $VerifiedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerifiedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerifiedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerifiedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> rootId = const Value.absent(),
            Value<int> at = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => VerifiedCompanion(rootId: rootId, at: at, rowid: rowid),
          createCompanionCallback: ({
            required String rootId,
            required int at,
            Value<int> rowid = const Value.absent(),
          }) => VerifiedCompanion.insert(rootId: rootId, at: at, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerifiedTable, VerifiedRow>(table),
                  BaseReferences<_$JaalDatabase, $VerifiedTable, VerifiedRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerifiedTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $VerifiedTable,
      VerifiedRow,
      $$VerifiedTableFilterComposer,
      $$VerifiedTableOrderingComposer,
      $$VerifiedTableAnnotationComposer,
      $$VerifiedTableCreateCompanionBuilder,
      $$VerifiedTableUpdateCompanionBuilder,
      (
        VerifiedRow,
        BaseReferences<_$JaalDatabase, $VerifiedTable, VerifiedRow>,
      ),
      VerifiedRow,
      PrefetchHooks Function()
    >;
typedef $$PetnamesTableCreateCompanionBuilder = PetnamesCompanion Function({
  required String rootId,
  required String name,
  Value<int> rowid,
});
typedef $$PetnamesTableUpdateCompanionBuilder = PetnamesCompanion Function({
  Value<String> rootId,
  Value<String> name,
  Value<int> rowid,
});

class $$PetnamesTableFilterComposer
    extends Composer<_$JaalDatabase, $PetnamesTable> {
  $$PetnamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PetnamesTableOrderingComposer
    extends Composer<_$JaalDatabase, $PetnamesTable> {
  $$PetnamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetnamesTableAnnotationComposer
    extends Composer<_$JaalDatabase, $PetnamesTable> {
  $$PetnamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$PetnamesTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $PetnamesTable,
          PetnameRow,
          $$PetnamesTableFilterComposer,
          $$PetnamesTableOrderingComposer,
          $$PetnamesTableAnnotationComposer,
          $$PetnamesTableCreateCompanionBuilder,
          $$PetnamesTableUpdateCompanionBuilder,
          (
            PetnameRow,
            BaseReferences<_$JaalDatabase, $PetnamesTable, PetnameRow>,
          ),
          PetnameRow,
          PrefetchHooks Function()
        > {
  $$PetnamesTableTableManager(_$JaalDatabase db, $PetnamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetnamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetnamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetnamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> rootId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PetnamesCompanion(rootId: rootId, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String rootId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => PetnamesCompanion.insert(
                rootId: rootId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PetnamesTable, PetnameRow>(table),
                  BaseReferences<_$JaalDatabase, $PetnamesTable, PetnameRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PetnamesTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $PetnamesTable,
      PetnameRow,
      $$PetnamesTableFilterComposer,
      $$PetnamesTableOrderingComposer,
      $$PetnamesTableAnnotationComposer,
      $$PetnamesTableCreateCompanionBuilder,
      $$PetnamesTableUpdateCompanionBuilder,
      (PetnameRow, BaseReferences<_$JaalDatabase, $PetnamesTable, PetnameRow>),
      PetnameRow,
      PrefetchHooks Function()
    >;
typedef $$MediaBlobsTableCreateCompanionBuilder = MediaBlobsCompanion Function({
  required String hash,
  required String manifest,
  required String mime,
  required int size,
  required int chunkCount,
  Value<int> chunksHeld,
  Value<bool> complete,
  required String rootId,
  required int createdAt,
  Value<int> rowid,
});
typedef $$MediaBlobsTableUpdateCompanionBuilder = MediaBlobsCompanion Function({
  Value<String> hash,
  Value<String> manifest,
  Value<String> mime,
  Value<int> size,
  Value<int> chunkCount,
  Value<int> chunksHeld,
  Value<bool> complete,
  Value<String> rootId,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$MediaBlobsTableFilterComposer
    extends Composer<_$JaalDatabase, $MediaBlobsTable> {
  $$MediaBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifest => $composableBuilder(
    column: $table.manifest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunksHeld => $composableBuilder(
    column: $table.chunksHeld,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get complete => $composableBuilder(
    column: $table.complete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaBlobsTableOrderingComposer
    extends Composer<_$JaalDatabase, $MediaBlobsTable> {
  $$MediaBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifest => $composableBuilder(
    column: $table.manifest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunksHeld => $composableBuilder(
    column: $table.chunksHeld,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get complete => $composableBuilder(
    column: $table.complete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootId => $composableBuilder(
    column: $table.rootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaBlobsTableAnnotationComposer
    extends Composer<_$JaalDatabase, $MediaBlobsTable> {
  $$MediaBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get manifest =>
      $composableBuilder(column: $table.manifest, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chunksHeld => $composableBuilder(
    column: $table.chunksHeld,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get complete =>
      $composableBuilder(column: $table.complete, builder: (column) => column);

  GeneratedColumn<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaBlobsTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $MediaBlobsTable,
          MediaBlobRow,
          $$MediaBlobsTableFilterComposer,
          $$MediaBlobsTableOrderingComposer,
          $$MediaBlobsTableAnnotationComposer,
          $$MediaBlobsTableCreateCompanionBuilder,
          $$MediaBlobsTableUpdateCompanionBuilder,
          (
            MediaBlobRow,
            BaseReferences<_$JaalDatabase, $MediaBlobsTable, MediaBlobRow>,
          ),
          MediaBlobRow,
          PrefetchHooks Function()
        > {
  $$MediaBlobsTableTableManager(_$JaalDatabase db, $MediaBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hash = const Value.absent(),
                Value<String> manifest = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<int> chunksHeld = const Value.absent(),
                Value<bool> complete = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaBlobsCompanion(
                hash: hash,
                manifest: manifest,
                mime: mime,
                size: size,
                chunkCount: chunkCount,
                chunksHeld: chunksHeld,
                complete: complete,
                rootId: rootId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hash,
                required String manifest,
                required String mime,
                required int size,
                required int chunkCount,
                Value<int> chunksHeld = const Value.absent(),
                Value<bool> complete = const Value.absent(),
                required String rootId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaBlobsCompanion.insert(
                hash: hash,
                manifest: manifest,
                mime: mime,
                size: size,
                chunkCount: chunkCount,
                chunksHeld: chunksHeld,
                complete: complete,
                rootId: rootId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaBlobsTable, MediaBlobRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $MediaBlobsTable,
                    MediaBlobRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $MediaBlobsTable,
      MediaBlobRow,
      $$MediaBlobsTableFilterComposer,
      $$MediaBlobsTableOrderingComposer,
      $$MediaBlobsTableAnnotationComposer,
      $$MediaBlobsTableCreateCompanionBuilder,
      $$MediaBlobsTableUpdateCompanionBuilder,
      (
        MediaBlobRow,
        BaseReferences<_$JaalDatabase, $MediaBlobsTable, MediaBlobRow>,
      ),
      MediaBlobRow,
      PrefetchHooks Function()
    >;
typedef $$MediaChunksTableCreateCompanionBuilder =
    MediaChunksCompanion Function({
      required String hash,
      required int idx,
      required Uint8List data,
      Value<int> rowid,
    });
typedef $$MediaChunksTableUpdateCompanionBuilder =
    MediaChunksCompanion Function({
      Value<String> hash,
      Value<int> idx,
      Value<Uint8List> data,
      Value<int> rowid,
    });

class $$MediaChunksTableFilterComposer
    extends Composer<_$JaalDatabase, $MediaChunksTable> {
  $$MediaChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaChunksTableOrderingComposer
    extends Composer<_$JaalDatabase, $MediaChunksTable> {
  $$MediaChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaChunksTableAnnotationComposer
    extends Composer<_$JaalDatabase, $MediaChunksTable> {
  $$MediaChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$MediaChunksTableTableManager
    extends
        RootTableManager<
          _$JaalDatabase,
          $MediaChunksTable,
          MediaChunkRow,
          $$MediaChunksTableFilterComposer,
          $$MediaChunksTableOrderingComposer,
          $$MediaChunksTableAnnotationComposer,
          $$MediaChunksTableCreateCompanionBuilder,
          $$MediaChunksTableUpdateCompanionBuilder,
          (
            MediaChunkRow,
            BaseReferences<_$JaalDatabase, $MediaChunksTable, MediaChunkRow>,
          ),
          MediaChunkRow,
          PrefetchHooks Function()
        > {
  $$MediaChunksTableTableManager(_$JaalDatabase db, $MediaChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hash = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaChunksCompanion(
                hash: hash,
                idx: idx,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hash,
                required int idx,
                required Uint8List data,
                Value<int> rowid = const Value.absent(),
              }) => MediaChunksCompanion.insert(
                hash: hash,
                idx: idx,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaChunksTable, MediaChunkRow>(table),
                  BaseReferences<
                    _$JaalDatabase,
                    $MediaChunksTable,
                    MediaChunkRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$JaalDatabase,
      $MediaChunksTable,
      MediaChunkRow,
      $$MediaChunksTableFilterComposer,
      $$MediaChunksTableOrderingComposer,
      $$MediaChunksTableAnnotationComposer,
      $$MediaChunksTableCreateCompanionBuilder,
      $$MediaChunksTableUpdateCompanionBuilder,
      (
        MediaChunkRow,
        BaseReferences<_$JaalDatabase, $MediaChunksTable, MediaChunkRow>,
      ),
      MediaChunkRow,
      PrefetchHooks Function()
    >;

class $JaalDatabaseManager {
  final _$JaalDatabase _db;
  $JaalDatabaseManager(this._db);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$ReactionsTableTableManager get reactions =>
      $$ReactionsTableTableManager(_db, _db.reactions);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db, _db.comments);
  $$FollowsTableTableManager get follows =>
      $$FollowsTableTableManager(_db, _db.follows);
  $$TombstonesTableTableManager get tombstones =>
      $$TombstonesTableTableManager(_db, _db.tombstones);
  $$EnvelopesTableTableManager get envelopes =>
      $$EnvelopesTableTableManager(_db, _db.envelopes);
  $$AcksTableTableManager get acks => $$AcksTableTableManager(_db, _db.acks);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$BlocksTableTableManager get blocks =>
      $$BlocksTableTableManager(_db, _db.blocks);
  $$PeersSeenTableTableManager get peersSeen =>
      $$PeersSeenTableTableManager(_db, _db.peersSeen);
  $$StatsTableTableManager get stats =>
      $$StatsTableTableManager(_db, _db.stats);
  $$ModActionsTableTableManager get modActions =>
      $$ModActionsTableTableManager(_db, _db.modActions);
  $$ModeratorsTableTableManager get moderators =>
      $$ModeratorsTableTableManager(_db, _db.moderators);
  $$ModStatusTableTableManager get modStatus =>
      $$ModStatusTableTableManager(_db, _db.modStatus);
  $$ModRevocationsTableTableManager get modRevocations =>
      $$ModRevocationsTableTableManager(_db, _db.modRevocations);
  $$VerifiedTableTableManager get verified =>
      $$VerifiedTableTableManager(_db, _db.verified);
  $$PetnamesTableTableManager get petnames =>
      $$PetnamesTableTableManager(_db, _db.petnames);
  $$MediaBlobsTableTableManager get mediaBlobs =>
      $$MediaBlobsTableTableManager(_db, _db.mediaBlobs);
  $$MediaChunksTableTableManager get mediaChunks =>
      $$MediaChunksTableTableManager(_db, _db.mediaChunks);
}

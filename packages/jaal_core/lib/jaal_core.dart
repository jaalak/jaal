/// Jaal core: protocol, identity, crypto, local-first storage, sync and
/// transport abstractions. Pure Dart — no Flutter dependency.
library;

export 'src/crypto/crypto.dart';
export 'src/db/database.dart';
export 'src/events/event_store.dart';
export 'src/events/projector.dart' show lwwNewer;
export 'src/identity/identity.dart';
export 'src/identity/lookalike.dart';
export 'src/identity/meet_code.dart';
export 'src/logging/log_buffer.dart';
export 'src/media/chunking.dart';
export 'src/media/media_store.dart';
export 'src/media/photo_compressor.dart';
export 'src/messaging/carrier.dart';
export 'src/messaging/envelope.dart';
export 'src/moderation/genesis_keys.dart';
export 'src/moderation/moderation_config.dart';
export 'src/moderation/moderation_engine.dart';
export 'src/node/jaal_node.dart';
export 'src/protocol/bodies.dart';
export 'src/protocol/event.dart';
export 'src/sync/replication_policy.dart';
export 'src/sync/sync_engine.dart';
export 'src/sync/sync_session.dart';
export 'src/transport/peer_transport.dart';
export 'src/transport/simulated_transport.dart';
export 'src/transport/rtc_signal.dart';
export 'src/transport/websocket_transport.dart';
export 'src/util/bytes.dart';
export 'src/util/canonical_json.dart';
export 'src/util/clock.dart';

part of 'inbox.dart';

class InboxQuery extends IQStanza {
  const InboxQuery({
    this.rsm,
  });

  final RSMSet? rsm;

  @override
  XmlElement toXML() {
    final element = WhixpUtils.xmlElement(
      name,
      namespace: namespace,
    );

    if (rsm != null) element.children.add(rsm!.toXML().copy());

    return element;
  }

  factory InboxQuery.fromXML(XmlElement node) {
    RSMSet? rsm;

    for (final child in node.children.whereType<XmlElement>()) {
      if (WhixpUtils.generateNamespacedElement(child) == rsmSetTag) {
        rsm = RSMSet.fromXML(child);
      }
    }

    return InboxQuery(
      rsm: rsm,
    );
  }

  @override
  String get name => "inbox";

  @override
  String get namespace => WhixpUtils.getNamespace('INBOX');

  @override
  String get tag => inboxQueryTag;
}

class InboxFin extends IQStanza {
  /// iq-fin stanza marks the end of the inbox query, Inbox query result IQ stanza returns the following values:
  /// count: the total number of conversations (if hidden_read value was set to true, this value will be equal to active_conversations)
  /// unread-messages: total number of unread messages from all conversations
  /// active-conversations: the number of conversations with unread message(s)
  const InboxFin({
    this.last,
    required this.count,
    required this.unreadMessages,
    required this.activeConversation,
  });

  final RSMSet? last;
  final int activeConversation;
  final int count;
  final int unreadMessages;

  @override
  XmlElement toXML() {
    final element = WhixpUtils.xmlElement(
      name,
      namespace: namespace,
    );

    if (last != null) element.children.add(last!.toXML().copy());

    element.children.add(
      WhixpUtils.xmlElement(
        "active-conversations",
        text: activeConversation.toString(),
      ),
    );

    element.children.add(
      WhixpUtils.xmlElement(
        "count",
        text: count.toString(),
      ),
    );

    element.children.add(
      WhixpUtils.xmlElement(
        "unread-messages",
        text: unreadMessages.toString(),
      ),
    );

    return element;
  }

  factory InboxFin.fromXML(XmlElement node) {
    RSMSet? last;
    int activeConversation = 0;
    int count = 0;
    int unreadMessages = 0;

    for (final child in node.children.whereType<XmlElement>()) {
      if (WhixpUtils.generateNamespacedElement(child) == rsmSetTag) {
        last = RSMSet.fromXML(child);
      } else if (child.name.toString() == "active-conversations") {
        activeConversation = int.parse(child.innerText);
      } else if (child.name.toString() == "count") {
        count = int.parse(child.innerText);
      } else if (child.name.toString() == "unread-messages") {
        unreadMessages = int.parse(child.innerText);
      }
    }

    return InboxFin(
      last: last,
      count: count,
      unreadMessages: unreadMessages,
      activeConversation: activeConversation,
    );
  }

  @override
  String get name => "fin";

  @override
  String get namespace => WhixpUtils.getNamespace('INBOX');

  @override
  String get tag => inboxFinTag;
}

/// none-or-many message stanzas are sent to the requesting resource describing each inbox entry
class InboxResult extends MessageStanza {
  const InboxResult({
    this.queryID,
    this.unread,
    this.forwarded,
    this.box,
    this.archive,
    this.mute,
  });

  final String? queryID;
  final int? unread;
  final Forwarded? forwarded;
  final String? box;
  final bool? archive;
  final bool? mute;

  @override
  XmlElement toXML() {
    final attributes = <String, String>{
      'xmlns': WhixpUtils.getNamespace('INBOX'),
    };

    if (queryID?.isNotEmpty ?? false) attributes['queryID'] = queryID!;
    if (unread != null) attributes['unread'] = unread.toString();

    final element = WhixpUtils.xmlElement(
      name,
      namespace: WhixpUtils.getNamespace('INBOX'),
      attributes: attributes,
    );
    if (forwarded != null) element.children.add(forwarded!.toXML().copy());
    return element;
  }

  factory InboxResult.fromXML(XmlElement node) {
    int? unread;
    String? queryID;
    Forwarded? forwarded;
    String? box;
    bool? archive;
    bool? mute;

    for (final attribute in node.attributes) {
      if (attribute.localName == 'queryid') {
        queryID = attribute.value;
      } else if (attribute.localName == "unread") {
        unread = int.parse(attribute.value);
      }
    }

    for (final child in node.children.whereType<XmlElement>()) {
      if (WhixpUtils.generateNamespacedElement(child) == forwardedTag) {
        forwarded = Forwarded.fromXML(child);
      } else if (child.name.toString() == "box") {
        box = child.innerText;
      } else if (child.name.toString() == "archive") {
        archive = child.innerText == "true";
      } else if (child.name.toString() == "mute") {
        mute = int.parse(child.innerText) == 1;
      }
    }

    return InboxResult(
      queryID: queryID,
      forwarded: forwarded,
      unread: unread,
      box: box,
      archive: archive,
      mute: mute,
    );
  }

  @override
  String get name => 'result';

  @override
  String get tag => inboxResultTag;
}

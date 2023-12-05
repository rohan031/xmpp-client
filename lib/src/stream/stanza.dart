part of 'base.dart';

class StanzaBase extends XMLBase {
  StanzaBase({
    Transport? transport,
    String? stanzaType,
    String? stanzaTo,
    String? stanzaFrom,
    String? stanzaID,
    Set<String> types = const <String>{},
    super.name,
    super.namespace,
    super.pluginAttribute,
    super.pluginMultiAttribute,
    super.overrides,
    super.pluginTagMapping,
    super.pluginAttributeMapping,
    super.interfaces,
    super.subInterfaces,
    super.boolInterfaces,
    super.languageInterfaces,
    super.pluginOverrides,
    super.pluginIterables,
    super.isExtension = false,
    super.includeNamespace = true,
    super.getters,
    super.setters,
    super.deleters,
    super.setupOverride,
    super.element,
    super.parent,
  }) {
    _transport = transport;

    _types = types;

    if (transport != null) {
      _namespace = transport.defaultNamespace;
    }

    if (stanzaType != null) {
      this['type'] = stanzaType;
    }
    if (stanzaTo != null) {
      this['to'] = JabberIDTemp(stanzaTo);
    }
    if (stanzaFrom != null) {
      this['from'] = JabberIDTemp(stanzaFrom);
    }
    if (stanzaID != null) {
      this['id'] = stanzaID;
    }

    addSetters({
      const Symbol('payload'): (value, args, base) =>
          setPayload([value as xml.XmlElement]),
    });

    addDeleters({const Symbol('payload'): (_, __) => deletePayload()});
  }

  late final Transport? _transport;
  late Set<String> _types;

  /// Sets the stanza's `type` attribute.
  void setType(String value) {
    if (_types.contains(value)) {
      element!.setAttribute('type', value);
    }
  }

  /// Returns the value of stanza's `to` attribute.
  JabberIDTemp get to => JabberIDTemp(_getAttribute('to'));

  /// Set the default `to` attribute of the stanza according to the passed [to]
  /// value.
  void setTo(String to) => setAttribute('to', to);

  /// Returns the value of stanza's `from` attribute.
  JabberIDTemp get from => JabberIDTemp(_getAttribute('from'));

  /// Set the default `to` attribute of the stanza according to the passed
  /// [frpm] value.
  void setFrom(String from) => setAttribute('from', from);

  /// Returns a [Iterable] of XML child elements.
  Iterable<xml.XmlElement> get payload => element!.childElements;

  /// Add [xml.XmlElement] content to the stanza.
  void setPayload(List<xml.XmlElement> values) {
    for (final value in values) {
      add(Tuple2(value, null));
    }
  }

  /// Remove the XML contents of the stanza.
  void deletePayload() => clear();

  /// Prepares the stanza for sending a reply.
  ///
  /// Swaps the `from` and `to` attributes.
  ///
  /// If [clear] is `true`, then also remove the stanza's contents to make room
  /// for the reply content.
  ///
  /// For client streams, the `from` attribute is removed.
  StanzaBase reply({bool clear = true}) {
    final newStanza = copy();

    if (_transport != null && _transport!.isComponent) {
      newStanza['from'] = this['to'];
      newStanza['to'] = this['from'];
    } else {
      newStanza['to'] = this['from'];
      newStanza.delete('from');
    }
    if (clear) {
      newStanza.clear();
    }

    return newStanza;
  }

  /// Set the stanza's type to `error`.
  StanzaBase error() {
    this['type'] = 'error';
    return this;
  }

  /// Called if no handlers have been registered to process this stanza.
  ///
  /// Mean to be overridden.
  void unhandled() {
    return;
  }

  /// Handle exceptions thrown during stanza processing.
  ///
  /// Meant to be overridden.
  void exception(Exception excp) {
    /// TODO: replace with proper log
    print('Exception handled in $_tag stanza: $excp');
  }

  void send() {
    if (_transport != null) {
      _transport!.send(Tuple2(this, null));
    } else {
      print('tried to send stanza without a stanza: $this');
    }
  }

  @override
  StanzaBase copy([xml.XmlElement? element, XMLBase? parent]) => StanzaBase(
        name: _name,
        namespace: _namespace,
        interfaces: _interfaces,
        pluginAttribute: _pluginAttribute,
        pluginTagMapping: _pluginTagMapping,
        pluginAttributeMapping: _pluginAttributeMapping,
        pluginMultiAttribute: _pluginMultiAttribute,
        overrides: _overrides,
        subInterfaces: _subInterfaces,
        boolInterfaces: _boolInterfaces,
        languageInterfaces: _languageInterfaces,
        pluginIterables: _pluginIterables,
        getters: _getters,
        setters: _setters,
        deleters: _deleters,
        isExtension: _isExtension,
        includeNamespace: _includeNamespace,
        setupOverride: setupOverride,
        transport: _transport,
        element: element,
        parent: parent,
      );
}
class Message {
  int id;
  String text;
  int conversationId;
  int writer;
  bool ia;

  Message(
      {this.id,
      this.text,
      this.conversationId,
      this.ia = false,
      this.writer = 0});
}

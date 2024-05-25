import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Option "mo:base/Option";

//ContactApp
actor {
  //Burada veri tabanını da biz temsil ettiğimizi için id tanımlaması yapıyoruz.
  type ContactId = Nat32; //Nat, doğal sayı demek ve 32 bit olacak.

  type Contact = { //Contact modeli oluşturduk.
    name: Text;
    phone: Text;
    email: Text;
    isFavorite: Bool;
    isBlokced: Bool;
  };

  type ResponseContact = {
    name: Text;
    phone: Text;
    email: Text;
    isFavorite: Bool;
    isBlokced: Bool;
    id: Nat32;
  };

  private stable var next:ContactId = 0; //İlk kaydımızda id değeri 0 olacak.

  //Burada tabloyu oluşturuyoruz.Id'ye göre ekleme, silme, güncellemeye yarar.
  private stable var contacts:Trie.Trie<ContactId,Contact> = Trie.empty();

  //Fonksiyonlarımızı yazıyoruz.
  //Her  bir contact id hash altında atanacak.Id'mizi hashleyip gönderiyoruz.
  private func key(x:ContactId) : Trie.Key<ContactId>{
    return {hash= x; key = x}; //
  };

  public func addContact(contact:Contact) : async Text {
    if(not validatePhoneNumber(contact.phone)) {
      return ("Phone number must be 10 digit");
    };
    let contactId = next;
    next +=1;

    contacts := Trie.replace(
      contacts,
      key(contactId),
      Nat32.equal,
      ?contact,
    ).0; //Trie'nin 0. indeksi ağaç yapısını döndürür.

    //İlgili veri tabanına id'ye göre ekleme 
    return ("Contact is created successful");

  };

  //Rehberi kullanıcıya göstermeye çalışıyoruz. [] array yapısını temsil eder.
  public func getContacts() : async [ResponseContact] {
    return Trie.toArray<ContactId,Contact,ResponseContact>(
      contacts,
      func (k,v){ //key value yani sözlük yapısı
        {id=k;name=v.name;phone=v.phone;email=v.email;isFavorite=v.isFavorite;isBlokced=v.isBlokced};
      }
    );
  };

  //Veriyi güncellemek
  public func updateContact(contactId:ContactId,contact:Contact): async Bool{
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);
    if(exists) {
      contacts := Trie.replace(
        contacts,
        key(contactId),
        Nat32.equal,
        ?contact,
      ).0;
    };
    return exists;
  };

  //Veriyi Silmek
  public func deleteContact(contactId:ContactId): async Bool{
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);//Veri var mı diye kontrol ediyoruz.
    if(exists) {
      contacts := Trie.replace(
        contacts,
        key(contactId),
        Nat32.equal,
        null,//Update'ten Tek fark burayı null yaptık
      ).0;
    };
    return exists;
  };

  //Telefon hanesini 11 haneli olacak şekilde validate etmek için
  private func validatePhoneNumber (phone:Text): Bool {
    if(phone.size()!=10) {
      return false;
    };
    return true;
  };

};

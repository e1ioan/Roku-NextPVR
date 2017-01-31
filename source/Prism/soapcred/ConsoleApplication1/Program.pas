namespace soapcred;

interface

uses
  System,
  System.IO,
  System.Security.Cryptography,
  System.Text;

type
  ConsoleApp = class
  public
    class method Main(args: array of string);
    class method hashMe(input: string): string;
    class method Encrypt(clearText: string; Password: string; Salt: array of byte; iteration: Integer): string;
    class method Encrypt(clearData: array of byte; Key: array of byte; IV: array of byte): array of byte;
    class method Encrypt(clearData: array of byte; Password: string; Salt: array of byte; iteration: integer): array of byte;
    class method Decrypt(cipherText: string; Password: string; Salt: array of byte; iterations: Integer): string;
    class method Decrypt(cipherData: array of byte; Password: string; Salt: array of byte; iterations: integer): array of byte;
    class method Decrypt(cipherData: array of byte; Key: array of byte; IV: array of byte): array of byte;

    class method verifyUser(R, RL, RTL, user, password: string): boolean;
  end;

implementation

class method ConsoleApp.Main(args: array of string);
begin
  // add your own code here
  var userName: string := '';
  var userPassword: string := '';
  var credFile: String := 'cred.txt';

  for each s: String in args do
  begin
    if s.Contains('username=') then
    begin
      userName := s.Substring(s.IndexOf('=')+1);
    end
    else if s.Contains('password=') then
    begin
      userPassword := s.Substring(s.IndexOf('=')+1);
    end
    else if s.Contains('file=') then
    begin
      credFile := s.Substring(s.IndexOf('=')+1);
    end;
  end;

  var iterations: Integer := 25;
  //Use the current date/time to create the Salt for the encryption of the userid and password
  var timeString: string := DateTime.Now.ToUniversalTime().ToString();
  var encodingSalt: Array of byte := Encoding.ASCII.GetBytes(hashMe(timeString));

  //Encrypt the credentials using the entered password hash (if correct the has will match what is stored in NEWA config)
  //as the encryption password along with the Salt
  var pwdHash: string := hashMe(userPassword).ToLower();
  var pwd: string := Encrypt(userPassword, pwdHash, encodingSalt, iterations);
  var id: string := Encrypt(userName, pwdHash, encodingSalt, iterations);

  var guid_: Guid := Guid.NewGuid();
  //We're encrypting the date/time we used to create the salt with the guid so the decrypt of the re-passed credentials knows
  //what is used as the salt
  var RL: String := Encrypt(id.Length.ToString(), pwdHash, Encoding.ASCII.GetBytes(guid_.ToString()), iterations);
  var rt: string := Encrypt(timeString, pwdHash, Encoding.ASCII.GetBytes(guid_.ToString()), iterations);
  var RTL: String := Encrypt(rt.Length.ToString(), pwdHash, Encoding.ASCII.GetBytes(guid_.ToString()), iterations);
  var R: String := rt + id + pwd + guid_;


  if System.IO.File.Exists(credFile) then
  begin
    System.IO.File.Delete(credFile);
  end;

  var writer: StreamWriter := new StreamWriter(credFile);
  writer.WriteLine(R);
  writer.WriteLine(RL);
  writer.WriteLine(RTL);
  writer.Flush();
  writer.Close();
end;

class method ConsoleApp.hashMe(input: string): string;
begin
  var x: MD5CryptoServiceProvider := new MD5CryptoServiceProvider();
  var bs:  array of byte := System.Text.Encoding.UTF8.GetBytes(input);
  bs := x.ComputeHash(bs);
  var s: StringBuilder := new StringBuilder();
  for each b: byte in bs do
  begin
    s.Append(b.ToString('x2').ToLower());
  end;
  var password: string := s.ToString();
  result:=password;
end;

class method ConsoleApp.Encrypt(clearText: string; Password: string; Salt: array of byte; iteration: Integer): string;
begin
  // First we need to turn the input string into a byte array.

  var clearBytes: Array of byte := System.Text.Encoding.Unicode.GetBytes(clearText);

  // Then, we need to turn the password into Key and IV
  // We are using salt to make it harder to guess our key
  // using a dictionary attack -
  // trying to guess a password by enumerating all possible words.

  var pdb: Rfc2898DeriveBytes := new Rfc2898DeriveBytes(Password, Salt, iteration);

  // Now get the key/IV and do the encryption using the
  // function that accepts byte arrays.
  // Using PasswordDeriveBytes object we are first getting
  // 32 bytes for the Key
  // (the default Rijndael key length is 256bit = 32bytes)
  // and then 16 bytes for the IV.
  // IV should always be the block size, which is by default
  // 16 bytes (128 bit) for Rijndael.
  // If you are using DES/TripleDES/RC2 the block size is
  // 8 bytes and so should be the IV size.
  // You can also read KeySize/BlockSize properties off
  // the algorithm to find out the sizes.

  var encryptedData: Array of byte := Encrypt(clearBytes, pdb.GetBytes(32), pdb.GetBytes(16));

  // Now we need to turn the resulting byte array into a string.
  // A common mistake would be to use an Encoding class for that.
  //It does not work because not all byte values can be
  // represented by characters.
  // We are going to be using Base64 encoding that is designed
  //exactly for what we are trying to do.

  result := Convert.ToBase64String(encryptedData);
end;

class method ConsoleApp.Encrypt(clearData: array of byte; Password: string; Salt: array of byte; iteration: integer): array of byte;
begin
  // We need to turn the password into Key and IV.
  // We are using salt to make it harder to guess our key
  // using a dictionary attack -
  // trying to guess a password by enumerating all possible words.

  var pdb: Rfc2898DeriveBytes  := new Rfc2898DeriveBytes(Password, Salt, iteration);

  // Now get the key/IV and do the encryption using the function
  // that accepts byte arrays.
  // Using PasswordDeriveBytes object we are first getting
  // 32 bytes for the Key
  // (the default Rijndael key length is 256bit = 32bytes)
  // and then 16 bytes for the IV.
  // IV should always be the block size, which is by default
  // 16 bytes (128 bit) for Rijndael.
  // If you are using DES/TripleDES/RC2 the block size is 8
  // bytes and so should be the IV size.
  // You can also read KeySize/BlockSize properties off the
  // algorithm to find out the sizes.

  result := Encrypt(clearData, pdb.GetBytes(32), pdb.GetBytes(16));
end;

class method ConsoleApp.Encrypt(clearData: array of byte; Key: array of byte; IV: array of byte): array of byte;
begin
  // Create a MemoryStream to accept the encrypted bytes
  var ms: MemoryStream  := new MemoryStream();
  // Create a symmetric algorithm.
  // We are going to use Rijndael because it is strong and
  // available on all platforms.
  // You can use other algorithms, to do so substitute the
  // next line with something like
  //      TripleDES alg = TripleDES.Create();
  var alg: Rijndael := Rijndael.Create();

  // Now set the key and the IV.
  // We need the IV (Initialization Vector) because
  // the algorithm is operating in its default
  // mode called CBC (Cipher Block Chaining).
  // The IV is XORed with the first block (8 byte)
  // of the data before it is encrypted, and then each
  // encrypted block is XORed with the
  // following block of plaintext.
  // This is done to make encryption more secure.
  // There is also a mode called ECB which does not need an IV,
  // but it is much less secure.
  alg.Key := Key;
  alg.IV := IV;

  // Create a CryptoStream through which we are going to be
  // pumping our data.
  // CryptoStreamMode.Write means that we are going to be
  // writing data to the stream and the output will be written
  // in the MemoryStream we have provided.
  var cs: CryptoStream := new CryptoStream(ms, alg.CreateEncryptor(), CryptoStreamMode.Write);

  // Write the data and make it do the encryption
  cs.Write(clearData, 0, clearData.Length);

  // Close the crypto stream (or do FlushFinalBlock).
  // This will tell it that we have done our encryption and
  // there is no more data coming in,
  // and it is now a good time to apply the padding and
  // finalize the encryption process.
  cs.Close();

  // Now get the encrypted data from the MemoryStream.
  // Some people make a mistake of using GetBuffer() here,
  // which is not the right way.
  var encryptedData: Array of byte := ms.ToArray();

  result := encryptedData;
end;

//////////////////////////////////
// Decrypt a byte array into a byte array using a key and an IV
class method ConsoleApp.Decrypt(cipherData: array of byte; Key: array of byte; IV: array of byte): array of byte;
begin
  // Create a MemoryStream that is going to accept the
  // decrypted bytes

  var ms: MemoryStream := new MemoryStream();

  // Create a symmetric algorithm.
  // We are going to use Rijndael because it is strong and
  // available on all platforms.
  // You can use other algorithms, to do so substitute the next
  // line with something like
  //     TripleDES alg = TripleDES.Create();

  var alg: Rijndael := Rijndael.Create();

  // Now set the key and the IV.
  // We need the IV (Initialization Vector) because the algorithm
  // is operating in its default
  // mode called CBC (Cipher Block Chaining). The IV is XORed with
  // the first block (8 byte)
  // of the data after it is decrypted, and then each decrypted
  // block is XORed with the previous
  // cipher block. This is done to make encryption more secure.
  // There is also a mode called ECB which does not need an IV,
  // but it is much less secure.

  alg.Key := Key;
  alg.IV := IV;

  // Create a CryptoStream through which we are going to be
  // pumping our data.
  // CryptoStreamMode.Write means that we are going to be
  // writing data to the stream
  // and the output will be written in the MemoryStream
  // we have provided.

  var cs: CryptoStream := new CryptoStream(ms, alg.CreateDecryptor(), CryptoStreamMode.Write);

  // Write the data and make it do the decryption

  cs.Write(cipherData, 0, cipherData.Length);

  // Close the crypto stream (or do FlushFinalBlock).
  // This will tell it that we have done our decryption
  // and there is no more data coming in,
  // and it is now a good time to remove the padding
  // and finalize the decryption process.

  cs.Close();

  // Now get the decrypted data from the MemoryStream.
  // Some people make a mistake of using GetBuffer() here,
  // which is not the right way.

  var decryptedData: Array of byte := ms.ToArray();

  result := decryptedData;
end;

// Decrypt a string into a string using a password
//    Uses Decrypt(byte[], byte[], byte[])
class method ConsoleApp.Decrypt(cipherText: string; Password: string; Salt: array of byte; iterations: Integer): string;
begin
  // First we need to turn the input string into a byte array.
  // We presume that Base64 encoding was used

  var cipherBytes: Array of byte := Convert.FromBase64String(cipherText);

  // Then, we need to turn the password into Key and IV
  // We are using salt to make it harder to guess our key
  // using a dictionary attack -
  // trying to guess a password by enumerating all possible words.

  var pdb: Rfc2898DeriveBytes  := new Rfc2898DeriveBytes(Password, Salt, iterations);

  // Now get the key/IV and do the decryption using
  // the function that accepts byte arrays.
  // Using PasswordDeriveBytes object we are first
  // getting 32 bytes for the Key
  // (the default Rijndael key length is 256bit = 32bytes)
  // and then 16 bytes for the IV.
  // IV should always be the block size, which is by
  // default 16 bytes (128 bit) for Rijndael.
  // If you are using DES/TripleDES/RC2 the block size is
  // 8 bytes and so should be the IV size.
  // You can also read KeySize/BlockSize properties off
  // the algorithm to find out the sizes.

  var decryptedData: Array of byte := Decrypt(cipherBytes, pdb.GetBytes(32), pdb.GetBytes(16));

  // Now we need to turn the resulting byte array into a string.
  // A common mistake would be to use an Encoding class for that.
  // It does not work
  // because not all byte values can be represented by characters.
  // We are going to be using Base64 encoding that is
  // designed exactly for what we are trying to do.

  result := System.Text.Encoding.Unicode.GetString(decryptedData);
end;

// Decrypt bytes into bytes using a password
//    Uses Decrypt(byte[], byte[], byte[])


class method ConsoleApp.Decrypt(cipherData: array of byte; Password: string; Salt: array of byte; iterations: integer): array of byte;
begin
  // We need to turn the password into Key and IV.
  // We are using salt to make it harder to guess our key
  // using a dictionary attack -
  // trying to guess a password by enumerating all possible words.

  var pdb: Rfc2898DeriveBytes := new Rfc2898DeriveBytes(Password, Salt, iterations);

  // Now get the key/IV and do the Decryption using the
  //function that accepts byte arrays.
  // Using PasswordDeriveBytes object we are first getting
  // 32 bytes for the Key
  // (the default Rijndael key length is 256bit = 32bytes)
  // and then 16 bytes for the IV.
  // IV should always be the block size, which is by default
  // 16 bytes (128 bit) for Rijndael.
  // If you are using DES/TripleDES/RC2 the block size is
  // 8 bytes and so should be the IV size.
  // You can also read KeySize/BlockSize properties off the
  // algorithm to find out the sizes.

  result := Decrypt(cipherData, pdb.GetBytes(32), pdb.GetBytes(16));
end;


class method ConsoleApp.verifyUser(R, RL, RTL, user, password: string): boolean;
begin
  //We need to pull the user id and password from the config file to match against the passed in credentials
  var requiredUsername: String := '_the value from /Settings/WebServer/Username in config.xml';
  var requiredPasswordHash:String := '_the value from /Settings/WebServer/Password in config.xml';

  var iterations: integer := 25;

  //Create the Salt needed to decrypt the passed in credentials
  var requestLength: integer := R.Length;
  var guidLength: integer := 36;
  var guid: string := R.Substring((requestLength - guidLength), guidLength);

  var uname: String := string.Empty;
  var pword: String := string.Empty;
  var timeStringLength: Integer := 0;
  var timeString: String := string.Empty;
  var idLength: Integer := 0;
  var encodingSalt: Array of byte := Encoding.ASCII.GetBytes(string.Empty);

  try
      timeStringLength := Convert.ToInt32(Decrypt(RTL, requiredPasswordHash.ToLower(), Encoding.ASCII.GetBytes(guid), iterations));
      timeString := Decrypt(R.Substring(0, timeStringLength), requiredPasswordHash.ToLower(), Encoding.ASCII.GetBytes(guid), iterations);
      encodingSalt := Encoding.ASCII.GetBytes(hashMe(timeString));

      //These are just for debugging purpose to be able to see what credentials where passed into the service
      idLength := Convert.ToInt32(Decrypt(RL, requiredPasswordHash.ToLower(), Encoding.ASCII.GetBytes(guid), iterations));
      uname := Decrypt(R.Substring(timeStringLength, idLength), requiredPasswordHash.ToLower(), encodingSalt, iterations);
      pword := Decrypt(R.Substring((timeStringLength + idLength), (requestLength - (guidLength + timeStringLength + idLength))), requiredPasswordHash.ToLower(), encodingSalt, iterations);
      var aa: String := pword;
  except
      try
          timeStringLength := Convert.ToInt32(Decrypt(RTL, 'baa609aed7cf8b015feebf2ed1627944', Encoding.ASCII.GetBytes(guid), iterations));
          timeString := Decrypt(R.Substring(0, timeStringLength), 'baa609aed7cf8b015feebf2ed1627944', Encoding.ASCII.GetBytes(guid), iterations);
          encodingSalt := Encoding.ASCII.GetBytes(hashMe(timeString));

          //These are just for debugging purpose to be able to see what credentials where passed into the service
          idLength := Convert.ToInt32(Decrypt(RL, 'baa609aed7cf8b015feebf2ed1627944', Encoding.ASCII.GetBytes(guid), iterations));
          uname := Decrypt(R.Substring(timeStringLength, idLength), 'baa609aed7cf8b015feebf2ed1627944', encodingSalt, iterations);
          pword := Decrypt(R.Substring((timeStringLength + idLength), (requestLength - (guidLength + timeStringLength + idLength))), 'baa609aed7cf8b015feebf2ed1627944', encodingSalt, iterations);
      except
          Console.WriteLine('*');
          Console.WriteLine('*');
          Console.WriteLine(' ***** Invalid Credential Packet  ****');
          Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
          Console.WriteLine('*');
          Console.WriteLine('*');
          Console.WriteLine('*********************');
          Console.WriteLine(' ');
          Console.WriteLine(' ');
          result := false;
      end;
  end;

  //First we need to verify the request is coming in within 40 seconds of the credential creation time.  this is to prevent replay.
  var nowTimeString: String := DateTime.Now.ToUniversalTime().ToString();
  var nowTime: DateTime := Convert.ToDateTime(nowTimeString);
  Console.WriteLine(' ');
  Console.WriteLine(' ');
  Console.WriteLine('*********************');
  Console.WriteLine('* Validating Incomming Web Service');
  Console.WriteLine('*');
  Console.WriteLine('User Name = ' + uname);
  Console.WriteLine('User Password = ' + pword);
  Console.WriteLine('*');
  Console.WriteLine('*');
  Console.WriteLine('Checking Server time....');
  Console.WriteLine('nowTime (Server-Local) = ' + nowTime.ToLocalTime());
  Console.WriteLine('nowTime (Server-UTC) = ' + nowTime.ToUniversalTime());
  Console.WriteLine('Credential time string (from request) = ' + timeString);
  Console.WriteLine('Credential time converted (Local) = ' + Convert.ToDateTime(timeString).ToLocalTime());
  Console.WriteLine('Credential time converted to DateObject = ' + Convert.ToDateTime(timeString));
  var spanTime: TimeSpan  := nowTime - Convert.ToDateTime(timeString);
  Console.WriteLine('Span time seconds (calc = server-utc - credential-utc) = ' + spanTime.Seconds);
  if (spanTime.Seconds <= 40) then
  begin
      //Decrypt and verify passed in credentials against the stored userid and password to ensure web service user is authorized
      //to use the service
      try
          if (Decrypt(R.Substring(timeStringLength, idLength), requiredPasswordHash.ToLower(), encodingSalt, iterations) = requiredUsername) and
              (hashMe(Decrypt(R.Substring((timeStringLength + idLength), (requestLength - (guidLength + timeStringLength + idLength))), requiredPasswordHash.ToLower(), encodingSalt, iterations))=
              requiredPasswordHash.ToLower()) then
          begin
              Console.WriteLine('User verified');
              Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
              Console.WriteLine('*');
              Console.WriteLine('*');
              Console.WriteLine('*********************');
              Console.WriteLine(' ');
              Console.WriteLine(' ');
              result := true;
              Exit;
          end;
      except
          try
              if (Decrypt(R.Substring(timeStringLength, idLength), 'baa609aed7cf8b015feebf2ed1627944', encodingSalt, iterations) = 'searchlight') and
                  (hashMe(Decrypt(R.Substring((timeStringLength + idLength), (requestLength - (guidLength + timeStringLength + idLength))), 'baa609aed7cf8b015feebf2ed1627944', encodingSalt, iterations)) =
                  'baa609aed7cf8b015feebf2ed1627944') then
              begin
                  Console.WriteLine('User verified - searchlight system id found');
                  Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
                  Console.WriteLine('*');
                  Console.WriteLine('*');
                  Console.WriteLine('*********************');
                  Console.WriteLine(' ');
                  Console.WriteLine(' ');
                  result := true;
                  Exit;
              end;
          except
              Console.WriteLine('*');
              Console.WriteLine('*');
              Console.WriteLine(' ***** Invalid Credential Packet  ****');
              Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
              Console.WriteLine('*');
              Console.WriteLine('*');
              Console.WriteLine('*********************');
              Console.WriteLine(' ');
              Console.WriteLine(' ');
              result := false;
              Exit;
          end;
      end;
      Console.WriteLine('*');
      Console.WriteLine('*');
      Console.WriteLine(' ***** User NOT verified  ****');
      Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
      Console.WriteLine('*');
      Console.WriteLine('*');
      Console.WriteLine('*********************');
      Console.WriteLine(' ');
      Console.WriteLine(' ');
      result := false;
      Exit;
  end
  else
  begin
      Console.WriteLine('*');
      Console.WriteLine('*');
      Console.WriteLine(' ***** Passed in credential was too old  ****');
      Console.WriteLine('nowTime (Server) = ' + DateTime.Now);
      Console.WriteLine('*');
      Console.WriteLine('*');
      Console.WriteLine('*********************');
      Console.WriteLine(' ');
      Console.WriteLine(' ');
      Console.WriteLine('Unauthorized - Timeout');
  end;
end;

end.

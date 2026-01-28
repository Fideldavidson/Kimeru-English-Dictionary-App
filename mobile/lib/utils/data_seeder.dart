import '../models/dictionary_entry.dart';
import '../services/local_database_service.dart';

class DataSeeder {
  static final List<Map<String, dynamic>> rawData = [
    {
      "headword": "a",
      "pos": "particle",
      "definitions": ["Used to form prepositions and conjunctions and to express adjectival concepts"],
      "examples": [
        {"kimeru": "Rūūji rwa kūng'ana", "english": "sufficient water"},
        {"kimeru": "a rūko", "english": "dirty"},
        {"kimeru": "a karaaja", "english": "ancient, of long ago"},
        {"kimeru": "a kūraaja", "english": "distant"}
      ]
    },
    {
      "headword": "a",
      "pos": "v.i.",
      "definitions": ["to be, to exist"],
      "note": "Forms: Ndĩ (I am), ūrī (you are), Arī (he/she is), tūrī (we are), būrī (you are), barî (they are). 'ni' is used for non-locative meanings.",
      "examples": [
        {"kimeru": "Ni bana", "english": "they are four"},
        {"kimeru": "tī", "english": "not to be"}
      ]
    },
    {
      "headword": "a",
      "pos": "v.t.",
      "definitions": ["to give, to present with, to donate"],
      "examples": [
        {"kimeru": "Ka", "english": "take (you sing)"},
        {"kimeru": "mpa", "english": "give me"},
        {"kimeru": "Ng'ina wa mpa nĩ akwire", "english": "the 'mother' of 'please give me' has died"}
      ]
    },
    {
      "headword": "aa?",
      "pos": "adv.",
      "definitions": ["where?, in what place?"],
      "examples": [{"kimeru": "Barĩ n'aa?", "english": "where are they?"}]
    },
    {
      "headword": "aama",
      "pos": "v.i.",
      "definitions": ["to be unable to speak", "to be foolish"]
    },
    {
      "headword": "aamia",
      "pos": "v.tr.",
      "definitions": ["to cause (someone) to be confused", "to frighten", "to keep one's mouth agape in astonishment"]
    },
    {
      "headword": "aana",
      "pos": "v.i.",
      "definitions": ["to go home, to retire, to withdraw", "to desert a husband", "children"]
    },
    {
      "headword": "aanda",
      "pos": "v.tr.",
      "definitions": ["to plant, to sow"]
    },
    {
      "headword": "aandikana",
      "pos": "v.tr.",
      "definitions": ["to engage labourers", "to prosecute reciprocally in court"]
    },
    {
      "headword": "aandīkithia",
      "pos": "v.tr.",
      "definitions": ["to cause to write, to dictate"]
    },
    {
      "headword": "aandukūra",
      "pos": "v.tr.",
      "definitions": ["to cancel, to erase what has been written"]
    },
    {
      "headword": "aanīria",
      "pos": "v.tr.",
      "definitions": ["to cheat openly, to mislead", "to be of the right size"],
      "examples": [{"kimeru": "anîîria nkunīki", "english": "test lid"}]
    },
    {
      "headword": "aatania",
      "pos": "v.i.",
      "definitions": ["to miss one another, to fail to meet", "not to fit"]
    },
    {
      "headword": "aatīra",
      "pos": "v.tr.",
      "definitions": ["to scratch something for someone else"],
      "examples": [{"kimeru": "Aatīra mwana gīkwa", "english": "scratch the yam for the child"}]
    },
    {
      "headword": "aba",
      "pos": "n.",
      "definitions": ["my father (term of respect used by men)"],
      "synonym": "baba"
    },
    {
      "headword": "abeco",
      "pos": "adv.",
      "definitions": ["almost, nearly, closely, on the brim of"],
      "examples": [{"kimeru": "Arī abeco gukua", "english": "he is in mortal danger"}]
    },
    {
      "headword": "acaara",
      "pos": "n.",
      "definitions": ["damage, loss in business"],
      "origin": "Swahili"
    },
    {
      "headword": "agaara",
      "pos": "v.tr.",
      "definitions": ["to transgress, to trespass", "to pass over, to surmount"]
    },
    {
      "headword": "agīra",
      "pos": "v.tr. & i.",
      "definitions": ["to improve, to become fitting", "to put a pot on the fire"],
      "examples": [{"kimeru": "Agīra nyongű", "english": "put the pot on the fire"}]
    },
    {
      "headword": "aīkia",
      "pos": "v.tr.",
      "definitions": ["to help someone to hoist a load"]
    },
    {
      "headword": "aja",
      "pos": "v.tr.",
      "definitions": ["to peel, to chop a crust away", "to carve", "to beat", "to sharpen"],
      "examples": [{"kimeru": "Kwaja karamu", "english": "to sharpen a pencil"}]
    },
    {
      "headword": "aka",
      "pos": "v.tr.",
      "definitions": ["to build, to make, to construct", "to paint, to polish, to anoint"],
      "examples": [{"kimeru": "gwaka rangi", "english": "to paint"}]
    },
    {
      "headword": "amba",
      "pos": "v.tr.",
      "definitions": ["to fix, to nail down", "to crucify", "to encamp", "to start"]
    },
    {
      "headword": "ambīīria",
      "pos": "v.tr.",
      "definitions": ["to start, to commence", "to collect something from above"]
    },
    {
      "headword": "amūkīra",
      "pos": "v.tr.",
      "definitions": ["to welcome, to receive, to accept, to receive Holy Communion"]
    },
    {
      "headword": "ana",
      "pos": "v.tr.",
      "definitions": ["to mark, to brand, to sign"]
    },
    {
      "headword": "angaīka",
      "pos": "v.i.",
      "definitions": ["to be worried, undecided, perplexed"]
    },
    {
      "headword": "ang'ūka",
      "pos": "v.i.",
      "definitions": ["to break off, to be deleted, to be cancelled"],
      "examples": [{"kimeru": "Mūtī jūkwang'ūka rwang'i", "english": "a branch has fallen from the tree"}]
    },
    {
      "headword": "anīka",
      "pos": "v.tr.",
      "definitions": ["to spread something out to dry"]
    },
    {
      "headword": "ankana",
      "pos": "v.i.",
      "definitions": ["to have boundaries in common", "to be contiguous"],
      "cf": "anka"
    },
    {
      "headword": "antū",
      "pos": "n.",
      "definitions": ["a period of time", "a small area, a definite place", "people (human beings)"],
      "examples": [{"kimeru": "Antū a mieri ithatu", "english": "for three months"}]
    },
    {
      "headword": "aramia",
      "pos": "v.tr.",
      "definitions": ["to extend, to widen, to expand"],
      "examples": [{"kimeru": "Nakwenda kwaramia nyomba", "english": "he wants to build an extension to his house"}]
    },
    {
      "headword": "arīka",
      "pos": "v.i.",
      "definitions": ["to be speakable, to offer the possibility of being discussed"],
      "examples": [{"kimeru": "Wīje ūmbarīīrie mūritani rūūjū", "english": "come and speak for me to the teacher tomorrow"}]
    },
    {
      "headword": "arithia",
      "pos": "v.tr.",
      "definitions": ["to cause looseness of bowels", "to cause to speak", "to switch on radio/TV"]
    },
    {
      "headword": "arūka",
      "pos": "v.tr.",
      "definitions": ["to begin something, to start a new thing"],
      "examples": [{"kimeru": "Kwaruka muunda", "english": "to start (cultivating) a new garden"}]
    },
    {
      "headword": "athana",
      "pos": "v.tr.",
      "definitions": ["to rule over, to govern, to be in authority"],
      "examples": [{"kimeru": "Atiūmba kwathana miaka itano", "english": "he will not be able to govern for five years"}]
    },
    {
      "headword": "athara",
      "pos": "n.",
      "definitions": ["loss, detriment, damage"],
      "cf": "acaara",
      "origin": "Swahili"
    },
    {
      "headword": "atīka",
      "pos": "v.tr.",
      "definitions": ["to push, to press hard, to force in", "to oppress"],
      "examples": [{"kimeru": "tiga kumbatīka!", "english": "stop pushing me!"}]
    }
  ];

  static Future<void> seed() async {
    final dbService = LocalDatabaseService();
    
    // Only seed if the database is empty to avoid blocking every launch
    final count = await dbService.countEntries();
    if (count > 0) return;

    final entries = rawData.map((e) => DictionaryEntry.fromJson(e)).toList();
    await dbService.insertOrUpdateEntries(entries);
  }
}

import 'package:blood_donation/donor_list.dart';
import 'package:flutter/material.dart';

class FindDonor extends StatefulWidget {
  @override
  _FindDonorState createState() => _FindDonorState();
}

class _FindDonorState extends State<FindDonor> {
  int currentStep = 0;
  String? selectedBloodGroup;
  String? selectedState;
  String? selectedDistrict;
  String enteredCity = '';

  List<String> bloodGroups = [
    'A+','A-','B+','B-','AB+','AB-','O+','O-','A1+','A1-','A2+','A2-','A1B+','A1B-','A2B+','A2B-'
  ];
  List<String> states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands', 'Chandigarh',
    'Dadra and Nagar Haveli', 'Daman and Diu', 'Delhi', 'Lakshadweep', 'Puducherry'
  ];

  Map<String, List<String>> stateDistricts = {
    'Andhra Pradesh': [
      'All','Kakinada','Dr. B. R. Ambedkar Konaseema','East Godavari','Eluru','Krishna','NTR','Guntur','Palnadu','Bapatla',
      'Prakasam','Sri Potti Sriramulu Nellore','Kurnool','Nandyal','Anantapuramu','Sri Sathya Sai','YSR','Annamayya','Tirupati','Chittoor',
    ],
    'Arunachal Pradesh': [
      'All',"Tawang","West Kameng","East Kameng","Papum Pare","Kurung Kumey","Kra Daadi","Lower Subansiri","Upper Subansiri","West Siang",
      "East Siang","Siang","Upper Siang","Lower Siang","Lower Dibang Valley","Dibang Valley","Anjaw","Lohit","Namsai","Changlang","Tirap",
      "Longding","Kamle","Pakke Kessang","Lepa Rada","Shi Yomi"
    ],
    'Assam': [
      'All',"Baksa","Barpeta","Bongaigaon","Cachar","Charaideo","Chirang","Darrang","Dhemaji","Dhubri","Dibrugarh","Goalpara","Golaghat",
      "Hailakandi","Hojai","Jorhat","Kamrup Metropolitan","Kamrup","Karbi Anglong","Karimganj","Kokrajhar","Lakhimpur","Majuli","Morigaon",
      "Nagaon","Nalbari","Dima Hasao","Sivasagar","Sonitpur","South Salmara-Mankachar","Tinsukia","Udalguri","West Karbi Anglong"
    ],
    'Bihar ': [
      'All',"Araria","Arwal","Aurangabad","Banka","Begusarai","Bhagalpur","Bhojpur","Buxar","Darbhanga","East Champaran (Motihari)","Gaya",
      "Gopalganj","Jamui","Jehanabad","Kaimur (Bhabua)","Katihar","Khagaria","Kishanganj","Lakhisarai","Madhepura","Madhubani","Munger (Monghyr)",
      "Muzaffarpur","Nalanda","Nawada","Patna","Purnia (Purnea)","Rohtas","Saharsa","Samastipur","Saran","Sheikhpura","Sheohar","Sitamarhi",
      "Siwan","Supaul","Vaishali","West Champaran"
    ],
    'Chhattisgarh': [
      'All',"Balod","Baloda Bazar","Balrampur","Bastar","Bemetara","Bijapur","Bilaspur","Dantewada (South Bastar)","Dhamtari","Durg","Gariaband",
      "Gaurela-Pendra-Marwahi","Janjgir-Champa","Jashpur","Kanker","Kawardha","Kondagaon","Korba","Koriya","Mahasamund","Mungeli","Narayanpur","Raigarh",
      "Raipur","Rajnandgaon","Sukma","Surajpur","Surguja"
    ],
    "Goa": ['All', "North Goa", "South Goa"],
    'Gujarat': [
      'All',"Ahmedabad","Amreli","Anand","Aravalli","Banaskantha","Bharuch","Bhavnagar","Botad","Chhota Udaipur","Dahod","Dang","Devbhoomi Dwarka","Gandhinagar",
      "Gir Somnath","Jamnagar","Junagadh","Kutch","Kheda","Mahisagar","Mehsana","Morbi","Narmada","Navsari","Panchmahal","Patan","Porbandar","Rajkot","Sabarkantha",
      "Surat","Surendranagar","Tapi","Vadodara","Valsad"
    ],
    'Haryana': [
      'All',"Ambala","Bhiwani","Charkhi Dadri","Faridabad","Fatehabad","Gurugram","Hisar","Jhajjar","Jind","Kaithal","Karnal","Kurukshetra","Mahendragarh","Nuh",
      "Palwal","Panchkula","Panipat","Rewari","Rohtak","Sirsa","Sonipat","Yamunanagar"
    ],
    "Himachal Pradesh": [
      'All',"Bilaspur","Chamba","Hamirpur","Kangra","Kinnaur","Kullu","Lahaul and Spiti","Mandi","Shimla","Sirmaur","Solan","Una" 
    ],
    "Jharkhand": [
      'All',"Bokaro","Chatra","Deoghar","Dhanbad","Dumka","East Singhbhum","Garhwa","Giridih","Godda","Gumla","Hazaribagh","Jamtara","Khunti","Koderma","Latehar",
      "Lohardaga","Pakur","Palamu","Ramgarh","Ranchi","Sahibganj","Seraikela Kharsawan","Simdega","West Singhbhum"
    ],
    "Karnataka": [
      'All',"Bagalkot","Ballari","Belagavi","Bengaluru Rural","Bengaluru Urban","Bidar","Chamarajanagar","Chikkaballapur","Chikkamagaluru","Chitradurga","Dakshina Kannada",
      "Davanagere","Dharwad","Gadag","Hassan","Haveri","Kalaburagi","Kodagu","Kolar","Koppal","Mandya","Mysuru","Raichur","Ramanagara","Shivamogga","Tumakuru","Udupi",
      "Uttara Kannada","Vijayapura","Yadgir"
    ],
    "Kerala": [
      'All',"Alappuzha","Ernakulam","Idukki","Kannur","Kasaragod","Kollam","Kottayam","Kozhikode","Malappuram","Palakkad","Pathanamthitta","Thiruvananthapuram","Thrissur","Wayanad"
    ],
    "Madhya Pradesh": [
      'All',"Agar Malwa","Alirajpur","Anuppur","Ashoknagar","Balaghat","Barwani","Betul","Bhind","Bhopal","Burhanpur","Chhatarpur","Chhindwara","Damoh","Datia","Dewas","Dhar",
      "Dindori","Guna","Gwalior","Harda","Hoshangabad","Indore","Jabalpur","Jhabua","Katni","Khandwa","Khargone","Mandla","Mandsaur","Morena","Narsinghpur","Neemuch","Panna",
      "Raisen","Rajgarh","Ratlam","Rewa","Sagar","Satna","Sehore","Seoni","Shahdol","Shajapur","Sheopur","Shivpuri","Sidhi","Singrauli","Tikamgarh","Ujjain","Umaria","Vidisha"
    ],
    "Maharashtra": [
      'All',"Ahmednagar","Akola","Amravati","Aurangabad","Beed","Bhandara","Buldhana","Chandrapur","Dhule","Gadchiroli","Gondia","Hingoli","Jalgaon","Jalna","Kolhapur","Latur",
      "Mumbai City","Mumbai Suburban","Nagpur","Nanded","Nandurbar","Nashik","Osmanabad","Palghar","Parbhani","Pune","Raigad","Ratnagiri","Sangli","Satara","Sindhudurg",
      "Solapur","Thane","Wardha","Washim","Yavatmal"
    ],
    "Manipur": [
      'All',"Bishnupur","Chandel","Churachandpur","Imphal East","Imphal West","Jiribam","Kakching","Kamjong","Kangpokpi","Noney","Pherzawl","Senapati","Tamenglong","Tengnoupal",
      "Thoubal","Ukhrul"
    ],
    "Meghalaya": [
      'All',"East Garo Hills","West Garo Hills","South Garo Hills","North Garo Hills","East Khasi Hills","West Khasi Hills","South West Khasi Hills","Ri-Bhoi",
      "South West Garo Hills","West Jaintia Hills","East Jaintia Hills"
    ],
    "Mizoram": [
      'All',"Aizawl","Champhai","Kolasib","Lawngtlai","Lunglei","Mamit","Saiha","Serchhip"
    ],
    "Nagaland": [
      'All',"Dimapur","Kiphire","Kohima","Longleng","Mokokchung","Mon","Peren","Phek","Tuensang","Wokha","Zunheboto"
    ],
    "Odisha": [
      'All',"Angul","Balangir","Balasore","Bargarh","Bhadrak","Boudh","Cuttack","Deogarh","Dhenkanal","Gajapati","Ganjam","Jagatsinghpur","Jajpur","Jharsuguda","Kalahandi",
      "Kandhamal","Kendrapara","Kendujhar","Khurda","Koraput","Malkangiri","Mayurbhanj","Nabarangpur","Nayagarh","Nuapada","Puri","Rayagada","Sambalpur","Sonepur","Sundargarh"
    ],
    "Punjab": [
      'All',"Amritsar","Barnala","Bathinda","Faridkot","Fatehgarh Sahib","Fazilka","Ferozepur","Gurdaspur","Hoshiarpur","Jalandhar","Kapurthala","Ludhiana","Mansa","Moga",
      "Muktsar","Pathankot","Patiala","Rupnagar","Sahibzada Ajit Singh Nagar","Sangrur","Shahid Bhagat Singh Nagar","Sri Muktsar Sahib","Tarn Taran"
    ],
    "Rajasthan ": [
      'All',"Ajmer","Alwar","Banswara","Baran","Barmer","Bharatpur","Bhilwara","Bikaner","Bundi","Chittorgarh","Churu","Dausa","Dholpur","Dungarpur","Hanumangarh","Jaipur",
      "Jaisalmer","Jalore","Jhalawar","Jhunjhunu","Jodhpur","Karauli","Kota","Nagaur","Pali","Pratapgarh","Rajsamand","Sawai Madhopur","Sikar","Sirohi","Sri Ganganagar","Tonk","Udaipur"
    ],
    "Sikkim": [
      'All',"East Sikkim","North Sikkim","South Sikkim","West Sikkim"
    ],
    "Tamil Nadu": [
      'All',"Ariyalur","Chengalpattu","Chennai","Coimbatore","Cuddalore","Dharmapuri","Dindigul","Erode","Kallakurichi","Kancheepuram","Kanyakumari","Karur","Krishnagiri",
      "Madurai","Nagapattinam","Namakkal","Nilgiris","Perambalur","Pudukkottai","Ramanathapuram","Ranipet","Salem","Sivaganga","Tenkasi","Thanjavur","Theni","Thiruvallur",
      "Thiruvarur","Thoothukudi","Tiruchirappalli","Tirunelveli","Tirupathur","Tiruppur","Tiruvannamalai","Vellore","Viluppuram","Virudhunagar"
    ],
    "Telangana": [
      'All',"Adilabad","Bhadradri Kothagudem","Hyderabad","Jagtial","Jangaon","Jayashankar Bhupalapally","Jogulamba Gadwal","Kamareddy","Karimnagar","Khammam","Komaram Bheem",
      "Mahabubabad","Mahabubnagar","Mancherial","Medak","Medchal-Malkajgiri","Mulugu","Nagarkurnool","Nalgonda","Nirmal","Nizamabad","Peddapalli","Rajanna Sircilla","Rangareddy",
      "Sangareddy","Siddipet","Suryapet","Vikarabad","Wanaparthy","Warangal Rural","Warangal Urban","Yadadri Bhuvanagiri"
    ],
    "Tripura": [
      'All',"Dhalai","Gomati","Khowai","North Tripura","Sepahijala","South Tripura","Unakoti","West Tripura"
    ],
    "Uttar Pradesh": [
      'All',"Agra","Aligarh","Allahabad","Ambedkar Nagar","Amethi","Amroha","Auraiya","Azamgarh","Baghpat","Bahraich","Ballia","Balrampur","Banda","Barabanki","Bareilly","Basti",
      "Bhadohi","Bijnor","Budaun","Bulandshahr","Chandauli","Chitrakoot","Deoria","Etah","Etawah","Faizabad","Farrukhabad","Fatehpur","Firozabad","Gautam Buddha Nagar","Ghaziabad",
      "Ghazipur","Gonda","Gorakhpur","Hamirpur","Hapur","Hardoi","Hathras","Jalaun","Jaunpur","Jhansi","Kannauj","Kanpur Dehat","Kanpur Nagar","Kasganj","Kaushambi","Kushinagar",
      "Lakhimpur Kheri","Lalitpur","Lucknow","Maharajganj","Mahoba","Mainpuri","Mathura","Mau","Meerut","Mirzapur","Moradabad","Muzaffarnagar","Pilibhit","Pratapgarh","Raebareli",
      "Rampur","Saharanpur","Sambhal","Sant Kabir Nagar","Shahjahanpur","Shamli","Shravasti","Siddharthnagar","Sitapur","Sonbhadra","Sultanpur","Unnao","Varanasi"
    ],
    "Uttarakhand": [
      'All',"Almora","Bageshwar","Chamoli","Champawat","Dehradun","Haridwar","Nainital","Pauri Garhwal","Pithoragarh","Rudraprayag","Tehri Garhwal","Udham Singh Nagar","Uttarkashi"
    ],
    "West Bengal": [
      'All',"Alipurduar","Bankura","Birbhum","Cooch Behar","Dakshin Dinajpur","Darjeeling","Hooghly","Howrah","Jalpaiguri","Jhargram","Kalimpong","Kolkata","Malda","Murshidabad",
      "Nadia","North 24 Parganas","Paschim Bardhaman","Paschim Medinipur","Purba Bardhaman","Purba Medinipur","Purulia","South 24 Parganas","Uttar Dinajpur"
    ],
    "Andaman and Nicobar Islands": [
      'All',"Nicobar","North and Middle Andaman","South Andaman"
    ],
    "Chandigarh": ["Chandigarh"],
    "Dadra and Nagar Haveli": ["Dadra and Nagar Haveli"],
    "Daman and Diu": ["Daman and Diu"],
    "Delhi": [
      'All',"Central Delhi","East Delhi","New Delhi","North Delhi","North East Delhi","North West Delhi","Shahdara","South Delhi","South East Delhi","South West Delhi","West Delhi"
    ],
    "Lakshadweep": ["Lakshadweep"],
    "Puducherry": ['All', "Karaikal", "Mahe", "Puducherry", "Yanam"],
  };

  List<String> districts = [];

  @override
  void initState() {
    super.initState();
    districts = stateDistricts[states[0]]!;
    selectedState = states[0];
    selectedDistrict = districts[0];
  }

  void navigateToDonorlist() {
    if (selectedBloodGroup != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonorListScreen(
            bloodGroup: selectedBloodGroup!,
            state: selectedState,
            district: selectedDistrict,
            city: enteredCity,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Validation Error'),
            content: Text('Please select a blood group.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Find A Donor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stepper(
                currentStep: currentStep,
                onStepContinue: () {
                  if (currentStep == 3) {
                    // Perform the search or save the data
                    // Replace this with your actual code
                    //  print('Blood group: $selectedBloodGroup');
                    //print('State: $selectedState');
                    //print('District: $selectedDistrict');
                    //print('City: $enteredCity');
                  }
                  setState(() {
                    if (currentStep < 3) {
                      currentStep += 1;
                    }
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (currentStep > 0) {
                      currentStep -= 1;
                    }
                  });
                },
                steps: [
                  Step(
                    title: const Text('Select Blood Group'),
                    isActive: currentStep == 0,
                    content: DropdownButtonFormField<String>(
                      value: selectedBloodGroup,
                      items: bloodGroups.map((String bloodGroup) {
                        return DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedBloodGroup = newValue!;
                        });
                      },
                    ),
                  ),
                  Step(
                    title: const Text('Select State'),
                    isActive: currentStep == 1,
                    content: DropdownButtonFormField<String>(
                      value: selectedState,
                      items: states.map((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedState = newValue!;
                          districts = stateDistricts[newValue]!;
                          selectedDistrict = districts[0];
                        });
                      },
                    ),
                  ),
                  Step(
                    title: const Text('Select District'),
                    isActive: currentStep == 2,
                    content: DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      items: districts.map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDistrict = newValue!;
                        });
                      },
                    ),
                  ),
                  Step(
                    title: const Text('Enter City'),
                    isActive: currentStep == 3,
                    content: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          enteredCity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: navigateToDonorlist,
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
}

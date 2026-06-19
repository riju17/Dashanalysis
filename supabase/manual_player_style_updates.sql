begin;

-- Apply batting and bowling style changes from the roster list
-- For rows with no style in a column, that column is left unchanged.

insert into players (id, player_name, team_id, role, batting_style, bowling_style, created_at)
values
  ('f9e2b8a7-5d31-5a14-9f3e-24d240001111', 'Priyanshu Shukla', '89c8bea7-a025-55f9-8858-3b1220253648', 'All-rounder', 'Right-hand bat', 'Right-arm medium fast', '2026-06-10T15:00:00')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_id = excluded.team_id,
  role = excluded.role,
  batting_style = excluded.batting_style,
  bowling_style = excluded.bowling_style,
  created_at = excluded.created_at
;

update players set batting_style = 'Right-hand bat' where id = 'b4fc481b-9d0c-5ffb-9bd7-576c9bbd0252'; -- Saksham Purohit
update players set batting_style = 'Right-hand bat' where id = 'b5bd61ff-5683-51bb-b5f9-4c60259e25c5'; -- Rakesh Thakur
update players set batting_style = 'Left-hand bat' where id = 'd2fda9b6-adf3-536b-b8d5-10529664d2c1'; -- Pankaj Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '5c41a2db-95b8-5fda-94cb-baf02e8545d3'; -- Ansh Yadav
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '580812e1-bbb3-5071-8e0b-bc7ce717c1e2'; -- Rishabh Chauhan
update players set batting_style = 'Right-hand bat' where id = '0fedfcd7-31fe-5be9-9e65-58daaf7d89e1'; -- Akhil Nigote
update players set batting_style = 'Right-hand bat' where id = 'fe7efb2f-9244-58c6-a3fd-55f32427a875'; -- Ashutosh Sharma
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '760c9582-173c-5107-8472-55496ef09cef'; -- Parth Sahani
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm wrist spin' where id = '8a5aad69-90e1-5713-b7f7-5bf83631cbc1'; -- Prashant Kasde
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '3d68aabb-51d3-51d6-9aa3-44c84c72caea'; -- Aditya Mishra
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '827fbd94-bf19-51e7-b3d8-24bca42f8d9b'; -- Harshwardhan Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd1aba495-c7db-5b97-850b-60e778095755'; -- Aryan Deshmukh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '75d0d91b-b3b6-5f3c-88af-7db4e964d45c'; -- Ishan Chaudhary
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd98dae83-73f6-5b91-a61d-c3988fe29777'; -- Vineet Rawat
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '17b7067e-ff1f-5a30-955b-b01d8a27702a'; -- Vivek Sharma
update players set batting_style = 'Left-hand bat' where id = '3313c4ab-7f84-51a6-a9db-707f3b4f0983'; -- Kuldeep Gehi
update players set batting_style = 'Right-hand bat' where id = '8f502ba1-ed08-5dd7-b9a1-9eeafda52406'; -- Vikas Sharma
update players set batting_style = 'Right-hand bat' where id = 'fb5bccb7-881d-5ed5-9fb7-521747fc08cb'; -- Varun Tiwari
update players set batting_style = 'Right-hand bat' where id = '3ea57ec9-dd66-5321-8669-ec767c467f61'; -- Parth Chaudhary
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c07ce930-7239-56c7-a87c-8dfab62436c5'; -- Kartik Parihar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '999836e6-f267-56b5-82fc-d874737ec447'; -- Vandit Joshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd6b5b3f7-4583-59e6-89a1-9b9f5e883ba2'; -- Saumy Pandey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'cfbc5a3c-7efa-5f50-b9a4-0bf3f2e2fa2a'; -- Akash Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'b199ea13-ead3-59fd-8f86-530506d3227a'; -- Ishan Afridi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '9f47f49c-29f6-5aaf-b21e-047fc3b72985'; -- Anubhav Agrawal
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f772a481-aac3-5e96-bdee-6f6466852b92'; -- Arpit Patel
update players set batting_style = 'Right-hand bat' where id = '687036d9-a074-5868-a9fd-310d8907a3ea'; -- Anil Maurya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f16fa647-c5f7-5d19-ac61-bba3be832560'; -- Tushar Verma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '4f062956-019c-5a34-82e6-2b4508a34d17'; -- Varun Shinde
update players set batting_style = 'Right-hand bat' where id = 'f6d907f4-f8bb-52aa-99ae-772bbf4b652a'; -- Rajat Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '40c90b46-0444-56dd-a8db-9fc2cef21a1b'; -- Mangesh Yadav
update players set batting_style = 'Right-hand bat' where id = 'bdfb9f70-ac54-5c21-b013-cc0c4ad44b45'; -- Aniket Verma
update players set batting_style = 'Left-hand bat' where id = 'c7022cce-a30e-54e0-972e-b076a0dee0c0'; -- Ansh Bagadia
update players set batting_style = 'Right-hand bat' where id = '15915c22-37bb-5f32-8ffe-ebd791791ed5'; -- Suraj Yadav
update players set batting_style = 'Right-hand bat' where id = 'd602bbdc-ef2a-53d4-a240-3c727a368bb4'; -- Anchit Thakur
update players set batting_style = 'Right-hand bat' where id = 'a652e185-c0c1-5361-9b36-14f575b0c276'; -- Rahul Chandrol
update players set batting_style = 'Right-hand bat' where id = 'e6d242cb-20f9-5d54-9009-e30b9805001f'; -- Kunal Rai
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'e8d4cbc5-c3e3-5276-ac3b-a3c363258fb3'; -- Kamal Tripathi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a1a052ca-de3c-5bc8-811f-fb5b9c0ca160'; -- Pranjal Puri
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'df7c6a07-1ed8-5d13-b601-f52736f8d7d6'; -- Himanshu Shinde
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'fcb64b16-e1c9-5810-8b52-311c6dc0dab0'; -- Tanishq Yadav
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '332c919b-7eac-5035-8014-dcc5dce42255'; -- Ajay Mishra
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '175f38b8-8402-57e3-a9ac-296f10ea624a'; -- Pawan Nirwani
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '8b2e24fd-e479-578d-928a-40a1ff1cf63e'; -- Amol Kasture
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'eb5862bd-322f-583b-a91a-728e1aa1d5ba'; -- Yuvraj Nema
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '3d0ebbab-1221-5ab5-a086-dcb55c9653b1'; -- Anurag Malwiya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c2af755b-5e2b-552e-84d5-f15701bf9248'; -- Manish Kumar
update players set batting_style = 'Left-hand bat' where id = '26fe523a-8080-5d6b-91df-2a56855d6b82'; -- Ojaswa Yadav
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = '4c5420f4-0540-53d4-ba92-5a185793cff3'; -- Shubham Kushwah
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin / Right-arm offbreak' where id = 'aab476d8-1b1e-5e64-b131-f8a20a926547'; -- Soham Patwardhan
update players set batting_style = 'Right-hand bat' where id = '8acb0d9d-2348-5e81-b225-c4b61ab10274'; -- Darshan Rathore
update players set batting_style = 'Right-hand bat' where id = '76c8afae-d578-5f7d-a434-bff3e9426dc8'; -- Chanchal Rathore
update players set batting_style = 'Right-hand bat' where id = 'c9704649-b025-5ae3-a7e1-58959be7b68c'; -- Yash Dubey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd58207e1-c9a0-5d95-a068-5c1ef03e6086'; -- Madhav Tiwari
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f37d1d1d-bd57-559c-9e29-7bebccc95480'; -- Aryan Pandey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '17ec0eb7-e6f6-5367-9484-40316d13e11d'; -- Ankur Singh Chauhan
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '5f9d6003-67e6-5524-b959-57d064eb9ac2'; -- Rishi Miglani
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '07f64c0c-c68f-5b8a-9ba5-efaf48a27ceb'; -- Harshwardhan Hardia
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '27d217d2-3af4-5405-a088-c7ef5ad6ac41'; -- Gajendra Goswami
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'e81c782b-8204-50d9-9e14-c0968343fe65'; -- Adheer Pratap Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '23350497-ca69-525f-b620-d61b88cb8670'; -- Aayush Mankar
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '6ff44d93-aa39-5b93-9d9e-4f4ee94696d2'; -- Masoom Raza Khan
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '04be1900-80cc-5f43-a46d-d1f0f514299e'; -- Naveen Nagle
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f398a1ab-b968-5027-b072-70586c71d93f'; -- Vishesh Mudgal
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm legbreak' where id = 'c3abcf6b-af87-50dd-b6cd-bef5ba923ff4'; -- Ankush Singh
update players set batting_style = 'Right-hand bat' where id = '810363ec-7c2f-59ec-b81f-071000960904'; -- Rohit Kumar Gupta
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'bdd646e4-e7c4-51c1-a3bf-f1bac631a751'; -- Shubham Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'bfd18390-21b9-5c61-8765-373789c7f2f2'; -- Aman Bhadoria
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '33e1f887-5e0a-513d-b17e-d50a5f9eae6f'; -- Gautam Raghuwanshi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '6d6158a0-64c1-5235-b5f3-55f601773dfd'; -- Harsh Dixit
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '8f53ea6e-5db4-5b51-beec-3cf622142bf7'; -- Tripuresh Singh
update players set batting_style = 'Right-hand bat' where id = '4787b00e-afcc-5f5d-8a98-f5d1b96283a1'; -- Karan Tiwari
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '84742574-8090-541e-b3ea-45031a5eaad5'; -- Diyanshu Yadav
update players set batting_style = 'Right-hand bat' where id = '1a2a261a-eab8-5945-805f-ab56e7ee4265'; -- Apurve Dwivedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '4beced42-4683-5cd7-a3d4-eafb40a735c1'; -- Avesh Khan
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '59efe8ae-f3df-5200-b756-93fd814d31c6'; -- Akshay Singh
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '661efd97-7f59-5db8-a791-fa9a2779d9cc'; -- Mayur Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = '8f1f6e57-aae3-54b2-b8e1-846e81517c05'; -- Piyush Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm wrist spin' where id = 'f25b9fd7-d8e1-5eeb-877b-84bd2138026c'; -- Yash Kumar Lodhi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '29b93c79-f1bc-5d03-ac0c-11d631feaed0'; -- Madhur Seth
update players set batting_style = 'Right-hand bat' where id = 'b1507fce-9244-5c38-bf11-cfc4aa6461d8'; -- Karan Tahliyani
update players set batting_style = 'Left-hand bat' where id = 'e934d378-43e4-5740-a2a1-abeda43b917e'; -- Atharv Joshi
update players set batting_style = 'Right-hand bat' where id = '21662ce5-2368-571f-8d64-26d735145aa5'; -- Siddarth Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = 'f56a747c-cd41-5456-ab5d-60a273526bf4'; -- Venkatesh Iyer
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = '9b8ce6e3-bb3b-56d0-8930-9c503e517e4d'; -- Anvesh Chawla
update players set batting_style = 'Left-hand bat' where id = '86a3bdf2-0579-543c-bd84-12d083001309'; -- Aayaam Verma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd4a25b3f-0333-564f-bc8b-8e57a3b41a99'; -- Saransh Surana
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '8c118ea4-e9c1-5620-a56e-885ee57dbd4a'; -- Shivam Shukla
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c8d836da-3c55-5fa1-b68a-2989f45aab44'; -- Roshan Kewat
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '0fc9b647-05ac-5f19-aefc-a3e704037c4e'; -- Akash Rajawat
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd52da864-1c4f-53e1-b7b4-94fc1879d773'; -- Vishnu Bhardwaj
update players set batting_style = 'Right-hand bat' where id = 'fab398ff-2405-564f-8d25-4e33023b20e6'; -- Arpit Gaud
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c92621ac-3bf1-5f82-b55e-215425cbb283'; -- Akarsh Singh Parihar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '925def19-3968-5442-b573-223adaf5a693'; -- Prince Wadhwani
update players set batting_style = 'Right-hand bat' where id = 'af9615ee-2603-5400-92a5-834a5d2719e9'; -- Ajay Rohera
update players set batting_style = 'Right-hand bat' where id = 'e9ab0e02-e7e6-5595-b7d0-8bb2891e2c4a'; -- Abhishek Bhandari
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '4d98b52f-c702-5ecb-9124-a36c23e956bc'; -- Puneet Datey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '29993758-c857-5658-9114-cc74a26c1880'; -- Ritik Tada
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'bb5c157d-7607-5723-9023-d11cc790cec7'; -- Nayan Raj Mewada
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm medium fast' where id = 'e02a6367-53de-5119-baf1-4affd88d2850'; -- Akshat Dwivedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '1f44fb2f-bd66-5467-bf4d-085daeb7c176'; -- Rahul Batham
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '14819b05-062e-56b6-a956-bc5711eb6673'; -- Sanjog Nijjar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '431edc70-c312-5536-a1ca-aab18576774f'; -- Vedant Awasthi
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = '0bc71b97-5af4-586d-96fb-ecbaa7affaab'; -- Pankaj Patel
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '03029869-5b08-58a5-8ba2-6af1ed546d6a'; -- Akshay Sharma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '7f3d49e1-bb8e-5a9a-b450-58ecbd064607'; -- Aayam Sardana
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '182f840e-6561-57f1-9ee9-ef9386fa72d3'; -- Mihir Hirwani
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '7a0298b6-de41-5113-9b49-7f1c5691ee5a'; -- Ritwik Diwan
update players set batting_style = 'Right-hand bat' where id = '14285295-0308-5eed-abb1-b4c02962a013'; -- Akshat Raghuwanshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm wrist spin' where id = '480c03c5-ea83-5913-8a4b-947fc3bf5a28'; -- Atharva Mahajan
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '98f0ac74-9b0a-56a2-a9a0-254195bcc80a'; -- Sagar Pratap Singh
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '26ed4478-2b30-5de3-ba83-96749866d006'; -- Arham Aqueel
update players set batting_style = 'Right-hand bat' where id = 'c1c0d96d-ac8e-5e26-a70c-c25f11359448'; -- Anant Verma
update players set batting_style = 'Right-hand bat' where id = 'b218001e-c822-58e7-ab99-da490578ae53'; -- Jaydev Singh
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'c30ccf9b-cb5c-55cb-9266-d50ec530797d'; -- Sagar Solanki
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '8ec8ffda-bfdc-54de-89d4-85e3d75f1ab3'; -- Prithviraj Tomar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd1b49b26-555f-569a-87eb-f55a7443c614'; -- Ankit Singh Kushwah
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a4edd760-ef34-5814-bb32-3e3a238042e2'; -- Naveen Singh Chauhan
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm medium fast' where id = 'a8bcd523-2f54-5dbe-bc14-55c5d83c4bf7'; -- Ramveer Singh Gurjar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '2b2f93bb-fe9d-5b14-abb3-6a5fe6c1a9c8'; -- Ashwin Das
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'cbdf43c9-cbd8-5235-936c-14d31366433c'; -- Rohit Rajawat
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium' where id = '170f726a-b896-5d70-a271-3ad3ec5eeab4'; -- Prabhanshu Shukla
update players set bowling_style = 'Left-arm medium fast' where id = 'f66e071a-cbc5-55b9-a19e-f985cc89bc54'; -- Ritesh Shakya
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = 'd08027f6-3fd4-56aa-a805-39c6005846c7'; -- Radhakrishna Dwivedi
update players set batting_style = 'Right-hand bat' where id = '7c3bef67-21bb-5f49-b72f-29484f10aa3c'; -- Parth Goswami
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '7f40be31-fc73-5139-a38d-5194608282e1'; -- Abhishek Pathak
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '3d2781b2-a98d-53e3-96a7-7640cf6ee944'; -- Rudransh Singh
update players set batting_style = 'Right-hand bat' where id = 'c8f284a8-e738-59e4-b7b5-ace9a37f6a2b'; -- Harsh Gawali
update players set batting_style = 'Right-hand bat' where id = '449bf9a5-34b1-52c1-9b27-9378f96cf184'; -- Kushagra Wadhwa
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm wrist spin' where id = 'e0b867ba-e046-579b-854b-4bf09ce97592'; -- Shvang Kumar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '3a6cb1d7-9e68-5074-8653-b57573a9f9eb'; -- Vikrant Bhadoriya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '2541f929-1c7b-5ec4-8e9d-6f8ae8f22ff8'; -- Anant Dubey
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = '660e82ef-f58e-562f-983e-53fc4a2d6b32'; -- Aman Jain
update players set bowling_style = 'Right-arm offbreak' where id = '1259d056-9bad-51ef-8ab7-caf13adcbff6'; -- Gautam Joshi
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = '0746cd79-5361-5ef8-ad53-8df4ee43b5bc'; -- Bhumesh Muzalda
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'd07905cb-9b4f-594a-972d-ceedba4bf8a6'; -- Kuldeep Sen
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '16ec489b-ec1f-537d-bf0e-431af7a9e9f8'; -- Omkarnath Singh
update players set batting_style = 'Right-hand bat' where id = '0e149403-3793-5acd-a209-daa0b036cfd5'; -- Harshit Parsai
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm medium fast' where id = '3dbfaf13-b0d2-5a9b-94ae-81c16fe26b47'; -- Yash Patidar
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = '3e1e44a2-bac8-5ece-8a5c-8c42201bd2be'; -- Milan Shivhare
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm offbreak' where id = 'c1ba6d40-d4f7-5671-97d7-da99594292a3'; -- Anand Singh Bais
update players set batting_style = 'Right-hand bat' where id = '930b10f7-a3a0-5f30-b2cc-34baf62ace88'; -- Abhishek Mavi
update players set batting_style = 'Left-hand bat' where id = 'b3959799-7ce4-5e1d-bedb-0612b04f822b'; -- Himanshu Mantri
update players set batting_style = 'Right-hand bat' where id = '8f2e9484-5216-5a56-9937-4c7fdf41c8d1'; -- Pranit Patidar
update players set batting_style = 'Left-hand bat', bowling_style = 'Right-arm offbreak' where id = 'f7ac72c3-f544-5a78-b5b5-d57f962c6811'; -- Saransh Jain
update players set batting_style = 'Right-hand bat' where id = '58201413-0f11-5f9f-9c43-5c1ce756ccf4'; -- Kanishk Dubey
update players set batting_style = 'Right-hand bat' where id = 'b0f804d9-8900-5473-8e3b-598a35cfd424'; -- Shantanu Raghuvanshi
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm legbreak' where id = 'b5b53032-9576-5eb8-933d-3ac8a9884f57'; -- Prarabdh Mishra
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'cfae1e19-cece-5fcb-9ca0-c6b8ea455378'; -- Pushkar Vishwakarma
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = '8c2ac304-10da-5dbc-b8e4-db6753b7c2a8'; -- Dharmesh Patel
update players set batting_style = 'Left-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'd15a9fe5-8630-5bd5-a764-7aebea809a9b'; -- Shivansh Chaturvedi
update players set batting_style = 'Right-hand bat', bowling_style = 'Left-arm orthodox spin' where id = 'e3731702-dacf-5e6a-9e4c-55ee74432723'; -- Kumar Kartikeya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'a4ef4c65-66ea-53eb-b3f6-49e455e0a0a4'; -- Kartik Rajoriya
update players set batting_style = 'Right-hand bat', bowling_style = 'Right-arm medium fast' where id = 'c2df7539-be90-5fcc-b9ee-bbaf45ea25c8'; -- Parush Mandal
commit;

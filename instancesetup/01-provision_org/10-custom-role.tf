// custom role for DPNCTF-15
# Source the permissions
data "datadog_permissions" "bar" {}

# Create a new Datadog role
resource "datadog_role" "customrole" {
  name = "CustomRoleForMyColleagues"
  permission {
    id = "984d2f00-d3b4-11e8-a200-bb47109e9987"
  }
  permission {

    id = "5e605652-dd12-11e8-9e53-375565b8970e"
  }
  permission {

    id = "62cc036c-dd12-11e8-9e54-db9995643092"
  }
  permission {

    id = "6f66600e-dd12-11e8-9e55-7f30fbb45e73"
  }
  permission {

    id = "7d7c98ac-dd12-11e8-9e56-93700598622d"
  }
  permission {

    id = "811ac4ca-dd12-11e8-9e57-676a7f0beef9"
  }
  permission {

    id = "84aa3ae4-dd12-11e8-9e58-a373a514ccd0"
  }
  permission {

    id = "87b00304-dd12-11e8-9e59-cbeb5f71f72f"
  }
  permission {

    id = "979df720-aed7-11e9-99c6-a7eb8373165a"
  }
  /*permission {

    id = "d90f6830-d3d8-11e9-a77a-b3404e5e9ee2"
  }*/
  permission {

    id = "d90f6831-d3d8-11e9-a77a-4fd230ddbc6a"
  }
  permission {

    id = "d90f6832-d3d8-11e9-a77a-bf8a2607f864"
  }
  /*permission {

    id = "4441648c-d8b1-11e9-a77a-1b899a04b304"
  }*/
  permission {

    id = "48ef71ea-d8b1-11e9-a77a-93f408470ad0"
  }
  permission {

    id = "4d87d5f8-d8b1-11e9-a77a-eb9c8350d04f"
  }
  permission {

    id = "1af86ce4-7823-11ea-93dc-d7cad1b1c6cb"
  }
  permission {

    id = "b382b982-8535-11ea-93de-2bf1bdf20798"
  }
  permission {

    id = "9ac1d8cc-e707-11ea-aa2d-73d37e989a9d"
  }
  permission {

    id = "9de604d8-e707-11ea-aa2d-93f1a783b3a3"
  }
  permission {

    id = "46a301da-ec5c-11ea-aa9f-73bedeab67ee"
  }
  permission {

    id = "46a301db-ec5c-11ea-aa9f-2fe72193d60e"
  }
  permission {

    id = "46a301dc-ec5c-11ea-aa9f-13b33f8f46ea"
  }
  permission {

    id = "46a301dd-ec5c-11ea-aa9f-97edfb345bc9"
  }
  permission {

    id = "46a301de-ec5c-11ea-aa9f-a73252c24806"
  }
  permission {

    id = "46a301df-ec5c-11ea-aa9f-970a9ae645e5"
  }
  permission {

    id = "46a301e0-ec5c-11ea-aa9f-6ba6cc675d8c"
  }
  permission {

    id = "46a301e1-ec5c-11ea-aa9f-afa39f6f3e36"
  }
  permission {

    id = "46a301e2-ec5c-11ea-aa9f-1f511b7305fd"
  }
  permission {

    id = "46a301e4-ec5c-11ea-aa9f-87282b3a50cc"
  }
  permission {

    id = "07c3c146-f7f8-11ea-acf6-0bd62b9ae60e"
  }
  permission {

    id = "2fbdac76-f923-11ea-adbc-07f3823e2b43"
  }
  permission {

    id = "372896c4-f923-11ea-adbc-4fecd107156d"
  }
  permission {

    id = "3e4d4d28-f923-11ea-adbc-e3565938c12e"
  }
  permission {

    id = "4628ca54-f923-11ea-adbc-4b2b7f88c5e9"
  }
  permission {

    id = "4ada6e36-f923-11ea-adbc-0788e5c5e3cf"
  }
  permission {

    id = "5025ee24-f923-11ea-adbc-576ea241df8d"
  }
  permission {

    id = "55f4b5ec-f923-11ea-adbc-1bfa2334a755"
  }
  permission {

    id = "5c6b88e2-f923-11ea-adbc-abf57d079420"
  }
  permission {

    id = "642eebe6-f923-11ea-adbc-eb617674ea04"
  }
  permission {

    id = "6ba32d22-0e1a-11eb-ba44-bf9a5aafaa39"
  }
  permission {

    id = "a42e94b2-1476-11eb-bd08-efda28c04248"
  }
  /*permission {

    id = "417ba636-2dce-11eb-84c0-6bce5b0d9de0"
  }*/
  permission {

    id = "43fa188e-2dce-11eb-84c0-835ad1fd6287"
  }
  permission {

    id = "465cfe66-2dce-11eb-84c0-6baa888239fa"
  }
  permission {

    id = "4916eebe-2dce-11eb-84c0-271cb2c672e8"
  }
  permission {

    id = "4e3f02b4-2dce-11eb-84c0-2fca946a6efc"
  }
  permission {

    id = "53950c54-2dce-11eb-84c0-a79ae108f6f8"
  }
  permission {

    id = "5cbe5f9c-2dce-11eb-84c0-872d3e9f1076"
  }
  permission {

    id = "61765026-2dce-11eb-84c0-833e230d1b8f"
  }
  permission {

    id = "04bc1cf2-340a-11eb-873a-43b973c760dd"
  }
  permission {

    id = "8106300a-54f7-11eb-8cbc-7781a434a67b"
  }
  permission {

    id = "edfd5e74-801f-11eb-96d8-da7ad0900002"
  }
  permission {

    id = "edfd5e75-801f-11eb-96d8-da7ad0900002"
  }
  permission {

    id = "bf0dcf7c-90af-11eb-9b82-da7ad0900002"
  }
  permission {

    id = "bf0dcf7d-90af-11eb-9b82-da7ad0900002"
  }
  permission {

    id = "7df222b6-a45c-11eb-a0af-da7ad0900002"
  }
  /*permission {

    id = "12efc20e-d36c-11eb-a9b8-da7ad0900002"
  }*/
  permission {

    id = "12efc211-d36c-11eb-a9b8-da7ad0900002"
  }
  permission {

    id = "12efc20f-d36c-11eb-a9b8-da7ad0900002"
  }
  permission {

    id = "12efc210-d36c-11eb-a9b8-da7ad0900002"
  }
  /*permission {

    id = "7605ef24-f376-11eb-b90b-da7ad0900002"
  }*/
  permission {

    id = "7605ef25-f376-11eb-b90b-da7ad0900002"
  }
  permission {

    id = "26c79920-1703-11ec-85d2-da7ad0900002"
  }
  permission {

    id = "020a563c-56a4-11ec-a982-da7ad0900002"
  }
  permission {

    id = "8e4d6b6e-5750-11ec-a9f4-da7ad0900002"
  }
  permission {

    id = "945b3bb4-5884-11ec-aa6d-da7ad0900002"
  }
  permission {

    id = "945b3bb5-5884-11ec-aa6d-da7ad0900002"
  }
  permission {

    id = "f6e917a8-8502-11ec-bf20-da7ad0900002"
  }
  permission {

    id = "f6e917aa-8502-11ec-bf20-da7ad0900002"
  }
  permission {

    id = "f6e917a9-8502-11ec-bf20-da7ad0900002"
  }
  permission {

    id = "f6e917a6-8502-11ec-bf20-da7ad0900002"
  }
  permission {

    id = "f6e917a7-8502-11ec-bf20-da7ad0900002"
  }
  permission {

    id = "7a89ec40-8b69-11ec-812d-da7ad0900002"
  }
  /*permission {

    id = "b6bf9ac6-9a59-11ec-8480-da7ad0900002"
  }*/
  permission {

    id = "b6bf9ac7-9a59-11ec-8480-da7ad0900002"
  }
  permission {

    id = "e35c06b0-966b-11ec-83c9-da7ad0900002"
  }
  permission {

    id = "2108215e-b9b4-11ec-958e-da7ad0900002"
  }
  permission {

    id = "7b1f5089-c59e-11ec-aa32-da7ad0900002"
  }
  permission {

    id = "1afff448-d5e9-11ec-ae37-da7ad0900002"
  }
  permission {

    id = "1afff449-d5e9-11ec-ae37-da7ad0900002"
  }
  permission {

    id = "6c87d3da-e5c5-11ec-b1d6-da7ad0900002"
  }
  /* Chris: unknown role id!?
  permission {

    id = "f8e941cf-e746-11ec-b22d-da7ad0900002"
  }*/
  permission {

    id = "f8e941d0-e746-11ec-b22d-da7ad0900002"
  }
  permission {

    id = "f8e941ce-e746-11ec-b22d-da7ad0900002"
  }
  permission {

    id = "4784b11c-f311-11ec-a5f5-da7ad0900002"
  }
  permission {

    id = "ee68fba9-173a-11ed-b00b-da7ad0900002"
  }
  permission {

    id = "ee68fba8-173a-11ed-b00b-da7ad0900002"
  }
  permission {

    id = "5b2c3e28-1761-11ed-b018-da7ad0900002"
  }
  permission {

    id = "36e2a22e-248a-11ed-b405-da7ad0900002"
  }
  permission {

    id = "8247acc4-7a4c-11ed-958f-da7ad0900002"
  }
  permission {

    id = "824851a6-7a4c-11ed-9590-da7ad0900002"
  }
  permission {

    id = "77d5f45e-7a5a-11ed-8abf-da7ad0900002"
  }
  permission {

    id = "77d55a44-7a5a-11ed-8abe-da7ad0900002"
  }
  /*permission {

    id = "6c5ad874-7aff-11ed-a5cd-da7ad0900002"
  }*/
  permission {

    id = "6c5c1090-7aff-11ed-a5cf-da7ad0900002"
  }
  permission {

    id = "6c59ae72-7aff-11ed-a5cc-da7ad0900002"
  }
  permission {

    id = "6c5b7428-7aff-11ed-a5ce-da7ad0900002"
  }
  permission {

    id = "6c5d0892-7aff-11ed-a5d0-da7ad0900002"
  }
  permission {

    id = "6c5de654-7aff-11ed-a5d1-da7ad0900002"
  }
  permission {

    id = "c13a2368-7d61-11ed-b5b7-da7ad0900002"
  }
  permission {

    id = "1d76ecfa-9771-11ed-9c2f-da7ad0900002"
  }
  permission {

    id = "4dc3eec6-b468-11ed-8539-da7ad0900002"
  }
  permission {

    id = "4dc4094c-b468-11ed-853a-da7ad0900002"
  }
  permission {

    id = "35dd33ea-ca2e-11ed-bca0-da7ad0900002"
  }
  permission {

    id = "36bf3d0a-ccc0-11ed-9453-da7ad0900002"
  }
  permission {

    id = "f416f55e-db3f-11ed-8028-da7ad0900002"
  }
  permission {

    id = "f416b1ac-db3f-11ed-8027-da7ad0900002"
  }
  permission {

    id = "4e61a95e-de98-11ed-aa23-da7ad0900002"
  }
  permission {

    id = "4e61ea18-de98-11ed-aa24-da7ad0900002"
  }
  permission {

    id = "8352cf04-f6ac-11ed-9ec7-da7ad0900002"
  }
  permission {

    id = "a773e3d8-fff2-11ed-965c-da7ad0900002"
  }
  permission {

    id = "a77452c8-fff2-11ed-965d-da7ad0900002"
  }
  permission {

    id = "a51b375a-ff73-11ed-8c18-da7ad0900002"
  }
  permission {

    id = "61f9891a-0070-11ee-9c3f-da7ad0900002"
  }
  permission {

    id = "1377d9e4-0ec7-11ee-aebc-da7ad0900002"
  }
  permission {

    id = "1377ff28-0ec7-11ee-aebd-da7ad0900002"
  }
  permission {

    id = "cc8cd958-11eb-11ee-ade2-da7ad0900002"
  }
  permission {

    id = "b1adb6e8-0949-11ee-b2c5-da7ad0900002"
  }
  permission {

    id = "b1adb5da-0949-11ee-b2c4-da7ad0900002"
  }
  permission {

    id = "785177a6-20da-11ee-bed7-da7ad0900002"
  }
  permission {

    id = "7850e390-20da-11ee-bed6-da7ad0900002"
  }
}

data "datadog_role" "adminrole" {
  filter = "Datadog Admin Role"
}

# Create a Dummy Datadog user to create Custom Role
resource "datadog_user" "dummy" {
  email = "dummy.tsre@datadoghq.com"

  roles = [datadog_role.customrole.id]
}

## Add users as Admin to the Orgs
resource "datadog_user" "users" {
    for_each = toset(var.dd_admins)
    
    email = each.value
    roles = [data.datadog_role.adminrole.id]
}
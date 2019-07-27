//
//  FriendsViewController.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI


class FriendsViewController: UIViewController, MFMessageComposeViewControllerDelegate, CNContactPickerDelegate {
    
    
    @IBOutlet var InviteButton: UIButton!
    
    @IBOutlet var myTableView: UITableView! {
        didSet {
            myTableView.dataSource = self as? UITableViewDataSource
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119 / 255, green: 139 / 255, blue: 235 / 255, alpha: 1.0)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getContactNumbers() -> [String]{
        fetchContacts { (contacts) in
            guard let allContacts = contacts else { return }
            
            print(allContacts.count)
            
            func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 1
            }
            
            func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return allContacts.count
            }
            
            func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath) as UITableViewCell
                
                cell.textLabel?.text = self.getContactNumbers()[indexPath.row]
                
                return cell
            }
            
        }
            // Now show these Contacts in a table view controller
            // In the table view controller, you can capture the selected contacts
            // Return the selected contacts
        
        return [""]
    }
    
    private func fetchContacts(completionHandler: @escaping ([MyContact]?) -> Void) {
        print("Attempting to fetch contacts today..")
        
        var allContacts = [MyContact]()
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
                        let givenName = contact.givenName
                        let familyName = contact.familyName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                        print(givenName)
                        print(familyName)
                        print(phoneNumber)
                        
                        let newContact = MyContact(givenName: givenName, familyName: familyName, phoneNumber: phoneNumber)
                        
                        allContacts.append(newContact)
                    })
                    
                    completionHandler(allContacts)
                    
                } catch let err {
                    print("Failed to enumerate contacts:", err)
                    completionHandler(nil)
                }
                
            } else {
                print("Access denied..")
                completionHandler(nil)
                
            }
        }
    }
    

    
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: (containerResults))
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    // NEW METHOD
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print(contact.phoneNumbers)
        let numbers = contact.phoneNumbers.first
        print((numbers?.value)?.stringValue ?? "")
        
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    //OLD METHOD
    func displayMessageInterface(selectedContacts: [String]) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        composeVC.recipients = []
        
        composeVC.body = ( "Download this new app here! itms://itunes.apple.com/de/app/x-gift/id839686104?mt=8&uo=4")
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        let selectedContacts = getContactNumbers()
        displayMessageInterface(selectedContacts: selectedContacts)
    }
    
    @IBAction func SearchContact(_ sender: Any) {
        let contacVC = CNContactPickerViewController()
        contacVC.delegate = self
        self.present(contacVC, animated: true, completion: nil)
    }
    
    }



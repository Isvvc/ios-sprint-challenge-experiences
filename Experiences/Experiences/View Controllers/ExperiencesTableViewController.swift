//
//  ExperiencesTableViewController.swift
//  Experiences
//
//  Created by Isaac Lyons on 12/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ExperiencesTableViewController: UITableViewController {
    
    var experienceController: ExperienceController?
    
    var audioPlayer: AVAudioPlayer?
    var audioPlayerIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experienceController?.experiences.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let experience = experienceController?.experiences[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExperienceCell", for: indexPath)
        cell.textLabel?.text = experience?.title
        
        if let imageData = experience?.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        }
        
        if experience?.audioURL != nil {
            cell.detailTextLabel?.text = "▶️"
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            experienceController?.removeExperience(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let experience = experienceController?.experiences[indexPath.row],
            let audioURL = experience.audioURL,
            let cell = tableView.cellForRow(at: indexPath) else { return }
        
        audioPlayer?.stop()
        resetPlayingCell()
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer.play()
            audioPlayer.delegate = self
            
            self.audioPlayer = audioPlayer
            audioPlayerIndexPath = indexPath
            
            cell.detailTextLabel?.text = "⏸"
        } catch {
            NSLog("Error getting audio player: \(error)")
        }
    }
    
    //MARK: Private
    
    private func resetPlayingCell() {
        if let indexPath = audioPlayerIndexPath,
            let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = "▶️"
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let experienceVC = segue.destination as? ExperienceViewController {
            experienceVC.experienceController = experienceController
        }
    }

}

//MARK: Audio Player Delegate

extension ExperiencesTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("Playback error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetPlayingCell()
    }
}

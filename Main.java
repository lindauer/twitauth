import twitter4j.*;

import java.io.*;
import java.util.ArrayList;
import java.util.List;


public class Main {

    public static void main(String[] args) {
        List<String> nameList = new ArrayList<String>();
        if(args.length==1){
            try {
                FileInputStream fis = new FileInputStream(args[0]);
                DataInputStream in = new DataInputStream(fis);
                BufferedReader br = new BufferedReader(new InputStreamReader(in));
                String strLine;
                while ((strLine = br.readLine()) != null)   {
                    // Print the content on the console
                    System.out.println (strLine);
                    nameList.add(strLine);
                }
                in.close();
            } catch (IOException ie) {
                ie.printStackTrace();
                System.out.println("Failed to read file: " + ie.getMessage());
                System.exit(-1);
            }
        } else {
            System.out.println("Missing Filename Input");
            System.exit(-1);
        }

        Twitter twitter = new TwitterFactory().getInstance();
        try {
            for (String name : nameList)  {
                List<Status> statuses = new ArrayList<Status>();
                Paging p = new Paging(1,200);
                for (int i=1;i<=5;i++){
                    p.setPage(i);

                    boolean complete = false;
                    while (!complete) {
                        try {
                            RateLimitStatus rls = twitter.getRateLimitStatus();
                            if (rls.getRemainingHits()==0){
                                System.out.println("*** RLS Limit Reached. Waiting " + Integer.toString(rls.getSecondsUntilReset()));
                                Thread.sleep(rls.getSecondsUntilReset()*1200);
                            }
                            System.out.println("Trying @" + name + " " + p);
                            statuses.addAll(twitter.getUserTimeline(name,p));
                            complete = true;
                        } catch (TwitterException twe) {
                            System.out.println("Failed Twitter Get Timeline: " + twe.getErrorMessage());
                            complete = false;
                        }
                    }
                }
                File fw= new File("\\csv\\" + name);
                fw.getParentFile().mkdirs();
                FileWriter writer = new FileWriter(fw);
                for (Status status : statuses) {
                    String tweetString = status.getText();
                    String retweetString = new String();
                    if (status.isRetweet()){
                        retweetString = status.getRetweetedStatus().getText();
                    }
                    tweetString = tweetString.replaceAll("\"", "\"\"");
                    retweetString = retweetString.replaceAll("\"", "\"\"");

                    int tweetnls=0;
                    for (int i=1;i<tweetString.length();i++) {
                        char c = tweetString.charAt(i);
                        if (c=='\n') tweetnls++;
                    }

                    int retweetnls=0;
                    for (int i=1;i<retweetString.length();i++) {
                        char c = retweetString.charAt(i);
                        if (c=='\n') retweetnls++;
                    }
                    tweetString = tweetString.replaceAll("\n"," ");
                    retweetString = retweetString.replaceAll("\n", " ");
                    writer.append("\"" + tweetString + "\"," + "\"" + Integer.toString(tweetnls) + "\"," + "\"" + retweetString + "\"," + "\"" + Integer.toString(retweetnls) + "\"" + "\n");
                }
                writer.close();
                File fso = new File("\\Serialized\\" + name + ".Serialized");
                fso.getParentFile().mkdirs();
                FileOutputStream f = new FileOutputStream(fso);
                ObjectOutputStream oos = new ObjectOutputStream(f);
                oos.writeObject(statuses);
                oos.close();
                System.out.println("@" + name + " " + Integer.toString(statuses.size()));
            }

        } catch (Exception te) {
            te.printStackTrace();
            System.out.println("Failed to write timeline: " + te.getMessage());
            System.exit(-1);
        }
    }
}


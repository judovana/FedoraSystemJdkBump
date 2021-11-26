package org.judovana.fedorajdkbump;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;

public interface Messagable {
    public Session getSession();
    public void sendMessage(Message message) throws MessagingException;
}
